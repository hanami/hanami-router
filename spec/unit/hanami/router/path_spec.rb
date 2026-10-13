# frozen_string_literal: true

RSpec.describe Hanami::Router do
  let(:router) do
    e = endpoint
    Hanami::Router.new(base_url: "https://hanami.test") do
      get "/hanami",               to: e, as: :fixed
      get "/flowers/:id",          to: e, as: :variables
      get "/books/:id", id: /\d+/, to: e, as: :constraints
      get "/articles(.:format)",   to: e, as: :optional
      get "/files/*glob",          to: e, as: :glob
    end
  end

  let(:endpoint) { ->(*) { [200, {}, ["Hi!"]] } }

  describe "#path" do
    it "recognizes fixed string" do
      expect(router.path(:fixed)).to eq("/hanami")
    end

    it "recognizes string with variables" do
      expect(router.path(:variables, id: "hanami")).to eq("/flowers/hanami")
    end

    it "raises error when variables aren't satisfied" do
      expect { router.path(:variables) }.to raise_error(Hanami::Router::InvalidRouteExpansionError, "No route could be generated for `:variables': cannot expand with keys [], possible expansions: [:id]")
    end

    it "recognizes string with variables and constraints" do
      expect(router.path(:constraints, id: 23)).to eq("/books/23")
    end

    it "recognizes optional variables" do
      expect(router.path(:optional)).to eq("/articles")
      expect(router.path(:optional, page: "1")).to eq("/articles?page=1")
      expect(router.path(:optional, format: "rss")).to eq("/articles.rss")
      expect(router.path(:optional, format: "rss", page: "1")).to eq("/articles.rss?page=1")
    end

    it "recognizes glob string" do
      expect(router.path(:glob)).to eq("/files/")
    end

    it "escapes additional params in query string" do
      expect(router.path(:fixed, return_to: "/dashboard")).to eq("/hanami?return_to=%2Fdashboard")
    end

    # FIXME: shall we keep this behavior?
    xit "raises error when insufficient params are passed" do
      expect { router.path(nil) }.to raise_error(Hanami::Router::InvalidRouteExpansionError, "No route could be generated for nil - please check given arguments")
    end
  end

  describe "#path, without Mustermann" do
    let(:router) do
      e = endpoint
      Hanami::Router.new do
        get "/hanami",                            to: e, as: :fixed
        get "/authors/:author_id/books/:id/edit", to: e, as: :variables
        get "/books/:id", id: /\d+/,              to: e, as: :constraints
        get "/:year-:month",                      to: e, as: :adjacent
      end
    end

    it "expands simple paths with plain values" do
      expect_any_instance_of(Mustermann::Rails).not_to receive(:expand)

      expect(router.path(:fixed)).to eq("/hanami")
      expect(router.path(:variables, author_id: 1, id: "hanami_2")).to eq("/authors/1/books/hanami_2/edit")
      expect(router.path(:constraints, id: 23)).to eq("/books/23")
      expect(router.path(:adjacent, year: 2026, month: 10)).to eq("/2026-10")
    end

    it "ignores constraints, as Mustermann does" do
      expect(router.path(:constraints, id: "hanami")).to eq("/books/hanami")
    end

    it "builds no Mustermann pattern for a fixed path" do
      e = endpoint
      expect(Mustermann).not_to receive(:new)

      router = Hanami::Router.new { get "/hanami", to: e, as: :fixed }

      expect(router.path(:fixed)).to eq("/hanami")
    end
  end

  describe "#path, compared with Mustermann" do
    routes = {
      fixed: ["/hanami"],
      variable: ["/flowers/:id"],
      variables: ["/authors/:author_id/books/:id/edit"],
      adjacent: ["/:year-:month"],
      format: ["/books/:id.:format"],
      constrained: ["/books/:id", {id: /\d+/}],
      optional: ["/articles(.:format)"],
      glob: ["/files/*glob"],
      escaped: ["/café/:id"]
    }

    values = [1, 0, 42, -1, "hanami", "hanami_2", "HANAMI", "", " ", "a b", "a/b", "a?b", "a#b", "a%b", "a.b", "a-b",
              "é", "x\n", "1.0", nil, :sym, 1.5]

    let(:router) do
      endpoint = ->(*) { [200, {}, ["Hi!"]] }

      Hanami::Router.new do
        routes.each do |name, (path, constraints)|
          get path, to: endpoint, as: name, **constraints.to_h
        end
      end
    end

    def mustermann_path(path, constraints, variables)
      Hanami::Router::Segment.fabricate(path, **constraints.to_h).expand(:append, variables)
    rescue Mustermann::ExpandError => exception
      exception.class
    end

    def router_path(name, variables)
      router.path(name, variables)
    rescue Hanami::Router::InvalidRouteExpansionError
      Mustermann::ExpandError
    end

    routes.each do |name, (path, constraints)|
      it "generates the same paths as Mustermann for #{path}" do
        names = Hanami::Router::Segment.fabricate(path, **constraints.to_h).names.map(&:to_sym)
        variable_sets = values.flat_map { |value| [names.to_h { |name| [name, value] }, names.to_h { |name| [name, value] }.merge(page: value)] }
        variable_sets += [{}, names.to_h { |name| [name.to_s, 1] }]

        variable_sets.uniq.each do |variables|
          expect(router_path(name, variables)).to eq(mustermann_path(path, constraints, variables)), "for #{variables.inspect}"
        end
      end
    end
  end
end
