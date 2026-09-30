# frozen_string_literal: true

RSpec.describe Hanami::Router::PathTemplate do
  describe ".fabricate" do
    def template_for(path, **constraints)
      described_class.fabricate(Hanami::Router::Segment.fabricate(path, **constraints))
    end

    it "builds a template for a route without variables" do
      expect(template_for("/hanami")).to be_a(described_class)
    end

    it "builds a template for a route with unconstrained variables" do
      expect(template_for("/authors/:author_id/books/:id")).to be_a(described_class)
    end

    it "builds no template for a route with a constrained variable" do
      expect(template_for("/books/:id", id: /\d+/)).to be_nil
    end

    it "builds a template when the constraints are for variables the route doesn't have" do
      expect(template_for("/books/:id", slug: /\w+/)).to be_a(described_class)
    end
  end

  describe "#expand" do
    subject(:template) { described_class.fabricate(Hanami::Router::Segment.fabricate("/authors/:author_id/books/:id/edit")) }

    it "fills in integer and plain string values" do
      expect(template.expand(author_id: 1, id: "hanami_2")).to eq("/authors/1/books/hanami_2/edit")
    end

    it "leaves missing, extra and string-keyed variables to Mustermann" do
      expect(template.expand(id: 1)).to be_nil
      expect(template.expand(author_id: 1, id: 2, page: 3)).to be_nil
      expect(template.expand("author_id" => 1, "id" => 2)).to be_nil
    end

    it "leaves values that may need escaping to Mustermann" do
      ["hanami book", "a/b", "é", "", "1.0", "x\n", -1].each do |value|
        expect(template.expand(author_id: 1, id: value)).to be_nil, "expected #{value.inspect} to be left to Mustermann"
      end
    end

    it "leaves nil, array and other values to Mustermann" do
      [nil, [1, 2], :hanami, 1.5].each do |value|
        expect(template.expand(author_id: 1, id: value)).to be_nil, "expected #{value.inspect} to be left to Mustermann"
      end
    end
  end

  describe "generating paths through the router" do
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
