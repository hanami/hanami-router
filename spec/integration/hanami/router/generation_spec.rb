# frozen_string_literal: true

RSpec.describe Hanami::Router do
  describe "generation" do
    let(:runner) { GenerationTestCase.new(router) }

    context "variable" do
      let(:router) do
        described_class.new do
          get "/:var", as: :a, to: -> {}
        end
      end

      it "generates relative and absolute URLs" do
        runner.run!([
          [:a, "/test", {var: "test"}],
          [:a, "/test", {var: "test"}]
        ])
      end
    end

    context "unicode variable" do
      let(:router) do
        described_class.new do
          get "/:var", as: :a, to: -> {}
        end
      end

      it "generates relative and absolute URLs" do
        runner.run!([
          [:a, "/%C3%A4", {var: "ä"}]
        ])
      end
    end

    context "multiple variables" do
      let(:router) do
        described_class.new do
          get "/:var/:baz", as: :a, to: -> {}
        end
      end

      it "generates relative and absolute URLs" do
        runner.run!([
          [:a, "/one/two", {var: "one", baz: "two"}]
        ])
      end
    end

    context "multiple fixed" do
      let(:router) do
        described_class.new do
          get "/",              as: :a, to: -> {}
          get "/test",          as: :b, to: -> {}
          get "/test/time",     as: :c, to: -> {}
          get "/one/more/what", as: :d, to: -> {}
          get "/test.html",     as: :e, to: -> {}
        end
      end

      it "generates relative and absolute URLs" do
        runner.run!([
          [:a, "/"],
          [:b, "/test"],
          [:c, "/test/time"],
          [:d, "/one/more/what"],
          [:e, "/test.html"]
        ])
      end
    end

    context "variable with query string" do
      let(:router) do
        described_class.new do
          get "/:var", as: :a, to: -> {}
        end
      end

      it "generates relative and absolute URLs" do
        runner.run!([
          [:a, "/test?query=string", {var: "test", query: "string"}]
        ])
      end
    end

    context "fixed with mandatory format" do
      let(:router) do
        described_class.new do
          get "/test.:format", as: :a, to: -> {}
        end
      end

      it "generates relative and absolute URLs" do
        runner.run!([
          [:a, "/test.html", {format: "html"}]
        ])
      end
    end

    context "fixed with optional format" do
      let(:router) do
        described_class.new do
          get "/test(.:format)", as: :a, to: -> {}
        end
      end

      it "generates relative and absolute URLs" do
        runner.run!([
          [:a, "/test.html", {format: "html"}],
          [:a, "/test"]
        ])
      end
    end

    context "variable with mandatory format" do
      let(:router) do
        described_class.new do
          get "/:var.:format", as: :a, to: -> {}
        end
      end

      it "generates relative and absolute URLs" do
        runner.run!([
          [:a, "/test.html", {var: "test", format: "html"}]
        ])
      end
    end

    context "variable with optional format" do
      let(:router) do
        described_class.new do
          get "/:var(.:format)", as: :a, to: -> {}
        end
      end

      it "generates relative and absolute URLs" do
        runner.run!([
          [:a, "/test.html", {var: "test", format: "html"}],
          [:a, "/test", {var: "test"}]
        ])
      end
    end

    context "variable with optional variable" do
      let(:router) do
        described_class.new do
          get "/:var1(/:var2)", as: :a, to: -> {}
        end
      end

      it "generates relative and absolute URLs" do
        runner.run!([
          [:a, "/foo/bar", {var1: "foo", var2: "bar"}],
          [:a, "/foo", {var1: "foo"}]
        ])
      end
    end

    context "variable with optional variable and format" do
      let(:router) do
        described_class.new do
          get "/:var1(/:var2.:format)", as: :a, to: -> {}
        end
      end

      xit "generates relative and absolute URLs" do
        runner.run!([
          [:a, "/test/test2.html", {var1: "test", var2: "test2", format: "html"}]
        ])
      end
    end

    context "variable with optional nested variables" do
      let(:router) do
        described_class.new do
          get "/:var1(/:var2(/:var3))", as: :a, to: -> {}
        end
      end

      it "generates relative and absolute URLs" do
        runner.run!([
          [:a, "/var/fooz/baz", {var1: "var", var2: "fooz", var3: "baz"}],
          [:a, "/var/fooz", {var1: "var", var2: "fooz"}],
          [:a, "/var", {var1: "var"}]
        ])
      end
    end
  end
end
