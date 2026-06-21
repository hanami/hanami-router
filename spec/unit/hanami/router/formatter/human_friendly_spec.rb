# frozen_string_literal: true

require "hanami/router/formatter/human_friendly"

RSpec.describe Hanami::Router::Formatter::HumanFriendly do
  describe "#call" do
    context "with no routes" do
      it "returns an empty string" do
        expect(subject.call([])).to eq("")
      end
    end

    context "with routes" do
      it "returns a human friendly representation of them" do
        routes = [
          Hanami::Router::Route.new(http_method: "GET", path: "/resources/:id", to: "resource#show", as: :resource, constraints: {id: /\d+/})
        ]

        expected = "GET     /resources/:id                     resource#show                      as :resource             (id: /\\d+/)                             "
        expect(subject.call(routes)).to eq(expected)
      end

      it "separates routes with line breaks" do
        routes = [
          Hanami::Router::Route.new(http_method: "GET", path: "/", to: "home#index", as: :root, constraints: {}),
          Hanami::Router::Route.new(http_method: "GET", path: "/about", to: "home#about", as: :root, constraints: {})
        ]

        rendered_routes = subject.call(routes).split($/)

        aggregate_failures do
          expect(rendered_routes.count).to be(2)
          expect(rendered_routes[0]).to include("home#index")
          expect(rendered_routes[1]).to include("home#about")
        end
      end

      it "doesn't include HEAD routes" do
        routes = [
          Hanami::Router::Route.new(http_method: "HEAD", path: "/resources/:id", to: "resource#show")
        ]

        expect(subject.call(routes)).not_to include("resource#show")
      end

      it "doesn't add empty lines for HEAD routes" do
        routes = [
          Hanami::Router::Route.new(http_method: "HEAD", path: "/about", to: "home#about", as: :root, constraints: {}),
          Hanami::Router::Route.new(http_method: "GET", path: "/about", to: "home#about", as: :root, constraints: {})
        ]

        expect(subject.call(routes).split($/).count).to be(1)
      end

      it "doesn't break when 'as' is not provided" do
        routes = [
          Hanami::Router::Route.new(http_method: "GET", path: "/resources/:id", to: "resource#show", constraints: {id: /\d+/})
        ]

        expect { subject.call(routes) }.not_to raise_error
      end

      it "doesn't break when 'constraints' is not provided" do
        routes = [
          Hanami::Router::Route.new(http_method: "GET", path: "/resources/:id", to: "resource#show", as: :resource)
        ]

        expect { subject.call(routes) }.not_to raise_error
      end
    end
  end
end
