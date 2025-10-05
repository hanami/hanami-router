# frozen_string_literal: true

RSpec.describe Hanami::Router do
  describe "recognition" do
    let(:runner) { RecognitionTestCase.new(router) }

    describe "empty path" do
      let(:router) do
        described_class.new do
          get "", as: :empty, to: RecognitionTestCase.endpoint("empty")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:empty, "/"],
          [:empty, ""]
        ])
      end
    end

    describe "fixed root" do
      let(:router) do
        described_class.new do
          get "/", as: :fixed, to: RecognitionTestCase.endpoint("fixed")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:fixed, "/"]
        ])
      end
    end

    describe "one fixed segment" do
      let(:router) do
        described_class.new do
          get "/test", as: :fixed, to: RecognitionTestCase.endpoint("fixed")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:fixed, "/test"]
        ])
      end
    end

    describe "two fixed segments" do
      let(:router) do
        described_class.new do
          get "/test/one", as: :fixed, to: RecognitionTestCase.endpoint("fixed")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:fixed, "/test/one"]
        ])
      end
    end

    describe "three fixed segments" do
      let(:router) do
        described_class.new do
          get "/test/one/two", as: :fixed, to: RecognitionTestCase.endpoint("fixed")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:fixed, "/test/one/two"]
        ])
      end
    end

    describe "one fixed segment with format" do
      let(:router) do
        described_class.new do
          get "/test.html", as: :fixed, to: RecognitionTestCase.endpoint("fixed")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:fixed, "/test.html"]
        ])
      end
    end

    describe "only format" do
      let(:router) do
        described_class.new do
          get ".html", as: :fixed, to: RecognitionTestCase.endpoint("fixed")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:fixed, "/.html"]
        ])
      end
    end

    describe "fixed unicode" do
      let(:router) do
        described_class.new do
          get "/føø", as: :fixed, to: RecognitionTestCase.endpoint("fixed")
        end
      end

      xit "recognizes route(s)" do
        runner.run!([
          [:fixed, "/f%C3%B8%C3%B8"]
        ])
      end
    end

    describe "globbed" do
      let(:router) do
        described_class.new do
          get "/*all", as: :globbed, to: RecognitionTestCase.endpoint("globbed")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:globbed, "/optional", {all: "optional"}],
          [:globbed, "/", {all: ""}]
        ])
      end
    end

    describe "multiple globbed routes" do
      let(:router) do
        described_class.new do
          get "/test*all", as: :globbed, to: RecognitionTestCase.endpoint("globbed")
          get "/*all",     as: :root,    to: RecognitionTestCase.endpoint("root")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:globbed, "/test/optional", {all: "/optional"}],
          [:globbed, "/test/optional/", {all: "/optional/"}],
          [:root, "/foo/optional", {all: "foo/optional"}]
        ])
      end
    end

    describe "relative variable" do
      let(:router) do
        described_class.new do
          get ":one", as: :variable, to: RecognitionTestCase.endpoint("variable")
        end
      end

      it "recognizes variable(s)" do
        runner.run!([
          [:variable, "/two", {one: "two"}]
        ])
      end
    end

    describe "relative unicode variable" do
      let(:router) do
        described_class.new do
          get ":var", as: :variable, to: RecognitionTestCase.endpoint("variable")
        end
      end

      xit "recognizes variable(s)" do
        runner.run!([
          [:variable, "/%E6%AE%BA%E3%81%99", {var: "殺す"}]
        ])
      end
    end

    describe "relative fixed with variable" do
      let(:router) do
        described_class.new do
          get "test/:one", as: :variable, to: RecognitionTestCase.endpoint("variable")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:variable, "/test/three", {one: "three"}]
        ])
      end
    end

    describe "relative fixed and relative variable" do
      let(:router) do
        described_class.new do
          get "one",  as: :fixed,    to: RecognitionTestCase.endpoint("fixed")
          get ":one", as: :variable, to: RecognitionTestCase.endpoint("variable")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:variable, "/two", {one: "two"}],
          [:fixed, "/one"]
        ])
      end
    end

    describe "relative variable with fixed and relative fixed" do
      let(:router) do
        described_class.new do
          get ":var/one", as: :variable, to: RecognitionTestCase.endpoint("variable")
          get "one",      as: :fixed,    to: RecognitionTestCase.endpoint("fixed")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:variable, "/two/one", {var: "two"}],
          [:fixed, "/one"],
          [nil, "/two"]
        ])
      end
    end

    describe "fixed with variable and fixed" do
      let(:router) do
        described_class.new do
          get "/foo/:id", as: :variable, to: RecognitionTestCase.endpoint("variable")
          get "/foo",     as: :fixed,    to: RecognitionTestCase.endpoint("fixed")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:variable, "/foo/id", {id: "id"}],
          [:fixed, "/foo"]
        ])
      end
    end

    describe "fixed and variable with fixed" do
      let(:router) do
        described_class.new do
          get "/foo/foo",   as: :fixed,    to: RecognitionTestCase.endpoint("fixed")
          get "/:foo/foo2", as: :variable, to: RecognitionTestCase.endpoint("variable")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:variable, "/foo/foo2", {foo: "foo"}],
          [:fixed, "/foo/foo"]
        ])
      end
    end

    describe "variable followed by variable with fixed with different slug names" do
      let(:router) do
        described_class.new do
          get "/:foo",     as: :variable_one, to: RecognitionTestCase.endpoint("variable_one")
          get "/:bar/baz", as: :variable_two, to: RecognitionTestCase.endpoint("variable_two")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:variable_one, "/one", {foo: "one"}],
          [:variable_two, "/two/baz", {bar: "two"}]
        ])
      end
    end

    describe "variable with fixed followed by variable with different slug names" do
      let(:router) do
        described_class.new do
          get "/:bar/baz", as: :variable_two, to: RecognitionTestCase.endpoint("variable_two")
          get "/:foo",     as: :variable_one, to: RecognitionTestCase.endpoint("variable_one")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:variable_one, "/one", {foo: "one"}],
          [:variable_two, "/two/baz", {bar: "two"}]
        ])
      end
    end

    describe "relative variable with constraints" do
      let(:router) do
        described_class.new do
          get ":foo", foo: /(test123|\d+)/, as: :variable, to: RecognitionTestCase.endpoint("variable")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:variable, "/test123", {foo: "test123"}],
          [:variable, "/123", {foo: "123"}],
          [nil, "/test123andmore"],
          [nil, "/lesstest123"]
        ])
      end
    end

    # FIXME: not supported in 2.2.1
    xdescribe "fixed with format" do
      let(:router) do
        described_class.new do
          get "/test.:format", as: :fixed, to: RecognitionTestCase.endpoint("fixed")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:fixed, "/test.html", {format: "html"}]
        ])
      end
    end

    # FIXME: not supported in 2.2.1
    xdescribe "fixed with optional format" do
      let(:router) do
        described_class.new do
          get "/test(.:format)", as: :fixed, to: RecognitionTestCase.endpoint("fixed")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:fixed, "/test.html", {format: "html"}],
          [:fixed, "/test", {format: nil}]
        ])
      end
    end

    # FIXME: decide if keep relative paths, or force to use only absolute format
    describe "relative optional format" do
      let(:router) do
        described_class.new do
          get "(.:format)", as: :fixed, to: RecognitionTestCase.endpoint("fixed")
        end
      end

      xit "recognizes route(s)" do
        runner.run!([
          # [:fixed, "/.html", { format: "html" }],
          [:fixed, "/", {format: nil}]
        ])
      end
    end

    # FIXME: not supported in 2.2.1
    xdescribe "variable with format" do
      let(:router) do
        described_class.new do
          get "/:test.:format", as: :variable, to: RecognitionTestCase.endpoint("variable")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:variable, "/foo.bar", {test: "foo", format: "bar"}]
        ])
      end
    end

    # FIXME: not supported in 2.2.1
    xdescribe "variable with optional format" do
      let(:router) do
        described_class.new do
          get "/:test(.:format)", as: :variable, to: RecognitionTestCase.endpoint("variable")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:variable, "/foo", {test: "foo", format: nil}],
          [:variable, "/foo.bar", {test: "foo", format: "bar"}]
        ])
      end
    end

    # FIXME: not supported in 2.2.1
    xdescribe "variable with optional constrainted format" do
      let(:router) do
        described_class.new do
          get "/:test(.:format)", format: /[^.]+/, as: :variable, to: RecognitionTestCase.endpoint("variable")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:variable, "/asd@asd.com.json", {test: "asd@asd.com", format: "json"}]
        ])
      end
    end

    describe "fixed with globbed variable" do
      let(:router) do
        described_class.new do
          get "/test/*variable", as: :globbed_variable, to: RecognitionTestCase.endpoint("globbed_variable")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:globbed_variable, "/test/one/two/three", {variable: "one/two/three"}]
        ])
      end
    end

    describe "relative fixed with globbed variable and fixed nested resource" do
      let(:router) do
        described_class.new do
          get "test/*variable/test", as: :globbed_variable, to: RecognitionTestCase.endpoint("globbed_variable")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:globbed_variable, "/test/one/two/three/test", {variable: "one/two/three"}],
          [nil, "/test/one/two/three"]
        ])
      end
    end

    describe "relative fixed with globbed variable, with nested resource and globbed variable" do
      let(:router) do
        described_class.new do
          get "test/*variable/test/*variable2", as: :globbed_variables, to: RecognitionTestCase.endpoint("globbed_variables")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:globbed_variables, "/test/one/two/three/test/four/five/six", {variable: "one/two/three", variable2: "four/five/six"}],
          [nil, "/test/one/two/three"]
        ])
      end
    end

    describe "fixed with variable and globbed variable in the same segment, plus format" do
      let(:router) do
        described_class.new do
          get "/test/:test-*variable.:format", as: :variables, to: RecognitionTestCase.endpoint("variables")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:variables, "/test/one-two/three/four/five.six", {test: "one", variable: "two/three/four/five", format: "six"}]
        ])
      end
    end

    describe "relative fixed with constrainted globbed variable" do
      let(:router) do
        described_class.new do
          get "test/*variable", as: :globbed_variable, variable: /[a-z]+/, to: RecognitionTestCase.endpoint("globbed_variable")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:globbed_variable, "/test/asd/123", {variable: "asd/123"}],
          [:globbed_variable, "/test/asd/asd123", {variable: "asd/asd123"}],
          [:globbed_variable, "/test/asd/qwe", {variable: "asd/qwe"}]
        ])
      end
    end

    describe "relative fixed with constrainted globbed variable and fixed nested resource" do
      let(:router) do
        described_class.new do
          get "test/*variable/test", as: :globbed_variable, variable: /[a-z]+/, to: RecognitionTestCase.endpoint("globbed_variable")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [nil, "/test/asd/123"],
          [nil, "/test/asd/asd123"],
          [nil, "/test/asd/qwe"],
          [:globbed_variable, "/test/asd/qwe/test", {variable: "asd/qwe"}]
        ])
      end
    end

    describe "relative fixed with constrainted globbed variable and variable nested resource" do
      let(:router) do
        described_class.new do
          get "test/*variable/:test", as: :globbed_variable, variable: /[a-z]+/, to: RecognitionTestCase.endpoint("globbed_variable")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:globbed_variable, "/test/asd/qwe/help", {variable: "asd/qwe", test: "help"}]
        ])
      end
    end

    describe "relative fixed with globbed variable and format" do
      let(:router) do
        described_class.new do
          get "test/*variable.:format", as: :globbed_variable, to: RecognitionTestCase.endpoint("globbed_variable")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:globbed_variable, "/test/asd/qwe.html", {variable: "asd/qwe", format: "html"}]
        ])
      end
    end

    describe "relative fixed with constrainted globbed variable and format" do
      let(:router) do
        described_class.new do
          get "test/*variable.:format", as: :globbed_variable, variable: /[a-z]+/, to: RecognitionTestCase.endpoint("globbed_variable")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [nil, "/test/asd/123"],
          [nil, "/test/asd/asd123"],
          [nil, "/test/asd/qwe"],
          [:globbed_variable, "/test/asd/qwe.html", {variable: "asd/qwe", format: "html"}]
        ])
      end
    end

    describe "relative fixed with constrainted globbed variable and optional format" do
      let(:router) do
        described_class.new do
          get "test/*variable(.:format)", as: :globbed_variable, variable: /[a-z]+/, to: RecognitionTestCase.endpoint("globbed_variable")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:globbed_variable, "/test/asd/123", {variable: "asd/123", format: nil}],
          [:globbed_variable, "/test/asd/asd123", {variable: "asd/asd123", format: nil}],
          [:globbed_variable, "/test/asd/qwe", {variable: "asd/qwe", format: nil}],
          [:globbed_variable, "/test/asd/qwe.html", {variable: "asd/qwe", format: "html"}]
        ])
      end
    end

    describe "relative fixed with globbed variable and fixed format" do
      let(:router) do
        described_class.new do
          get "test/*variable.html", as: :globbed_variable, to: RecognitionTestCase.endpoint("globbed_variable")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [nil, "/test/asd/123"],
          [:globbed_variable, "/test/asd/qwe.html", {variable: "asd/qwe"}]
        ])
      end
    end

    describe "multiple routes with variables, constraints and verbs" do
      let(:router) do
        described_class.new do
          get  "/:common_variable/:matched",   as: :regex, matched: /\d+/, to: RecognitionTestCase.endpoint("regex")
          post "/:common_variable/:matched",   as: :post,                  to: RecognitionTestCase.endpoint("post")
          get  "/:common_variable/:unmatched", as: :noregex,               to: RecognitionTestCase.endpoint("noregex")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:regex, "/common/123", {common_variable: "common", matched: "123"}],
          # FIXME
          # [:noregex, '/common/other', { common_variable: 'common', unmatched: 'other' }],
          [:post, "/common/123", {common_variable: "common", matched: "123"}, "POST"],
          [:post, "/common/other", {common_variable: "common", matched: "other"}, "POST"]
        ])
      end
    end

    describe "multiple routes with variables and constraints" do
      let(:router) do
        described_class.new do
          get ":test/number",   as: :regex, test: /\d+/, to: RecognitionTestCase.endpoint("regex")
          get ":test/anything", as: :greedy, to: RecognitionTestCase.endpoint("greedy")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:regex, "/123/number", {test: "123"}],
          [:greedy, "/123/anything", {test: "123"}]
        ])
      end
    end

    describe "variable with permissive constraint" do
      let(:router) do
        described_class.new do
          get "/:test", as: :regex, test: /.*/, to: RecognitionTestCase.endpoint("regex")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:regex, "/test.html", {test: "test.html"}]
        ])
      end
    end

    describe "relative variable with numeric constraint" do
      let(:router) do
        described_class.new do
          get ":test", as: :regex, test: /\d+/, to: RecognitionTestCase.endpoint("regex")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:regex, "/123", {test: "123"}],
          [nil, "/a123"]
        ])
      end
    end

    describe "optional fixed segment" do
      let(:router) do
        described_class.new do
          get "/one(/two)", as: :nested, to: RecognitionTestCase.endpoint("nested")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:nested, "/one"],
          [:nested, "/one/two"]
        ])
      end
    end

    describe "optional variable segment" do
      let(:router) do
        described_class.new do
          get "/one(/:two)", as: :nested, to: RecognitionTestCase.endpoint("nested")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:nested, "/one", {}],
          [:nested, "/one/2", {two: "2"}]
        ])
      end
    end

    describe "optional variable between fixed segments" do
      let(:router) do
        described_class.new do
          get "/one(/:var)/two", as: :nested, to: RecognitionTestCase.endpoint("nested")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:nested, "/one/two", {}],
          [:nested, "/one/abc/two", {var: "abc"}]
        ])
      end
    end

    describe "consecutive optional variables" do
      let(:router) do
        described_class.new do
          get "/one(/:year)(/:month)/two", as: :nested, to: RecognitionTestCase.endpoint("nested")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:nested, "/one/two", {}],
          [:nested, "/one/1970/two", {year: "1970"}],
          [:nested, "/one/1970/12/two", {year: "1970", month: "12"}]
        ])
      end
    end

    describe "consecutive optional variables with constraints" do
      let(:router) do
        described_class.new do
          get "/one(/:year)(/:month)", as: :nested, to: RecognitionTestCase.endpoint("nested"), year: /\d{4}/, month: /\d{2}/
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:nested, "/one", {}],
          [:nested, "/one/1970", {year: "1970"}],
          [:nested, "/one/12", {month: "12"}],
          [:nested, "/one/1970/12", {year: "1970", month: "12"}]
        ])
      end
    end

    describe "multiple nested optional fixed segments" do
      let(:router) do
        described_class.new do
          get "one(/two(/three(/four)(/five)))", as: :nested, to: RecognitionTestCase.endpoint("nested")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:nested, "/one"],
          [:nested, "/one/two"],
          [:nested, "/one/two/three"],
          [:nested, "/one/two/three/four"],
          [:nested, "/one/two/three/five"],
          [:nested, "/one/two/three/four/five"],
          [nil, "/one/two/four/five"]
        ])
      end
    end

    describe "invalid optional definition" do
      let(:router) do
        described_class.new do
          get "/one(/two", as: :broken, to: RecognitionTestCase.endpoint("broken")
        end
      end

      it "raise InvalidRouteDefinitionError" do
        expect { runner }.to raise_error(Hanami::Router::InvalidRouteDefinitionError)
      end
    end

    # FIXME: not supported in 2.2.1
    xdescribe "relative fixed with escaped variable" do
      let(:router) do
        described_class.new do
          get "test\\:variable", as: :escaped, to: RecognitionTestCase.endpoint("escaped")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:escaped, "/test:variable"]
        ])
      end
    end

    # FIXME: not supported in 2.2.1
    xdescribe "relative fixed with escaped optional variable" do
      let(:router) do
        described_class.new do
          get "test\\(:variable\\)", as: :escaped, to: RecognitionTestCase.endpoint("escaped")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:escaped, "/test(hello)", {variable: "hello"}]
        ])
      end
    end

    describe "relative fixed with escaped globbed variable" do
      let(:router) do
        described_class.new do
          get "test\\*variable", as: :escaped, to: RecognitionTestCase.endpoint("escaped")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:escaped, "/test*variable"]
        ])
      end
    end

    describe "relative fixed with escaped glob" do
      let(:router) do
        described_class.new do
          get "testvariable\\*", as: :escaped, to: RecognitionTestCase.endpoint("escaped")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:escaped, "/testvariable*"]
        ])
      end
    end

    # FIXME: not supported in 2.2.1
    xdescribe "variable sourrounded by fixed tokens in the same segment" do
      let(:router) do
        described_class.new do
          get "/one-:variable-time", as: :variable, to: RecognitionTestCase.endpoint("variable")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:variable, "/one-value-time", {variable: "value"}]
        ])
      end
    end

    # FIXME: not supported in 2.2.1
    xdescribe "constrainted variable sourrounded by fixed tokens in the same segment" do
      let(:router) do
        described_class.new do
          get "/one-:variable-time", as: :variable, variable: /\d+/, to: RecognitionTestCase.endpoint("variable")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:variable, "/one-123-time", {variable: "123"}],
          [nil, "/one-value-time"]
        ])
      end
    end

    # FIXME: not supported in 2.2.1
    xdescribe "variable sourrounded by fixed token and format in the same segment" do
      let(:router) do
        described_class.new do
          get "hey.:greed.html", as: :variable, to: RecognitionTestCase.endpoint("variable")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:variable, "/hey.greedybody.html", {greed: "greedybody"}]
        ])
      end
    end

    # FIXME: not supported in 2.2.1
    xdescribe "multiple routes with variables in the same segment" do
      let(:router) do
        described_class.new do
          get "/:v1-:v2-:v3-:v4-:v5-:v6", as: :var6, to: RecognitionTestCase.endpoint("var6")
          get "/:v1-:v2-:v3-:v4-:v5",     as: :var5, to: RecognitionTestCase.endpoint("var5")
          get "/:v1-:v2-:v3-:v4",         as: :var4, to: RecognitionTestCase.endpoint("var4")
          get "/:v1-:v2-:v3",             as: :var3, to: RecognitionTestCase.endpoint("var3")
          get "/:v1-:v2",                 as: :var2, to: RecognitionTestCase.endpoint("var2")
          get "/:v1",                     as: :var1, to: RecognitionTestCase.endpoint("var1")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:var1, "/one", {v1: "one"}],
          [:var2, "/one-two", {v1: "one", v2: "two"}],
          [:var3, "/one-two-three", {v1: "one", v2: "two", v3: "three"}],
          [:var4, "/one-two-three-four", {v1: "one", v2: "two", v3: "three", v4: "four"}],
          [:var5, "/one-two-three-four-five", {v1: "one", v2: "two", v3: "three", v4: "four", v5: "five"}],
          [:var6, "/one-two-three-four-five-six", {v1: "one", v2: "two", v3: "three", v4: "four", v5: "five", v6: "six"}]
        ])
      end
    end

    # FIXME: not supported in 2.2.1
    xcontext "variable sourrounded by fixed token and format in the same segment" do
      let(:router) do
        described_class.new do
          get "/:common_variable.:matched",   as: :regex,   to: RecognitionTestCase.endpoint("regex"), matched: /\d+/
          get "/:common_variable.:unmatched", as: :noregex, to: RecognitionTestCase.endpoint("noregex")
        end
      end

      it "recognizes route(s)" do
        runner.run!([
          [:regex, "/common.123", {common_variable: "common", matched: "123"}],
          [:noregex, "/common.other", {common_variable: "common", unmatched: "other"}]
        ])
      end
    end
  end
end
