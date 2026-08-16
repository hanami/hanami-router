# frozen_string_literal: true

require "hanami/router/inspector"

RSpec.describe Hanami::Router do
  describe "#routes" do
    it "records every route, without an inspector" do
      router = described_class.new do
        get "/books", to: "books.index", as: :books
        post "/books", to: "books.create"
      end

      expect(router.routes.map { |route| [route.http_method, route.path] }).to eq(
        [
          ["GET", "/books"],
          ["HEAD", "/books"],
          ["POST", "/books"]
        ]
      )
    end

    it "records the details given at definition time" do
      router = described_class.new do
        get "/books/:id", to: "books.show", as: :book, id: /\d+/
      end

      route = router.routes.first

      expect(route.path).to eq("/books/:id")
      expect(route.to).to eq("books.show")
      expect(route.as).to eq(:book)
      expect(route.constraints).to eq(id: /\d+/)
    end

    it "is empty for a router without routes" do
      expect(described_class.new.routes).to eq([])
    end

    it "records routes defined within a scope, with their prefixed path and name" do
      router = described_class.new do
        scope "api" do
          get "/books", to: "books.index", as: :books
        end
      end

      route = router.routes.first

      expect(route.path).to eq("/api/books")
      expect(route.as).to eq(:api_books)
    end

    it "records routes defined with a router prefix" do
      router = described_class.new(prefix: "/admin") do
        get "/books", to: "books.index"
      end

      expect(router.routes.first.path).to eq("/admin/books")
    end

    it "records mounted apps" do
      app = ->(*) { [200, {}, ["OK"]] }

      router = described_class.new do
        mount app, at: "/api"
      end

      route = router.routes.first

      expect(route.http_method).to eq("*")
      expect(route.path).to eq("/api")
      expect(route.to).to be(app)
    end

    it "records redirects" do
      router = described_class.new do
        redirect "/old", to: "/new", code: 301
      end

      expect(router.routes.first.inspect_to).to eq("/new (HTTP 301)")
    end

    it "records routes given a block endpoint" do
      router = described_class.new do
        get "/books" do
          "OK"
        end
      end

      route = router.routes.first

      expect(route.path).to eq("/books")
      expect(route.inspect_to).to eq("(block)")
    end

    it "records the same routes given to an inspector" do
      inspector = Hanami::Router::Inspector.new(formatter: ->(routes) { routes })

      router = described_class.new(inspector: inspector) do
        get "/books", to: "books.index"
        mount ->(*) { [200, {}, ["OK"]] }, at: "/api"
      end

      expect(router.routes).to eq(inspector.call)
    end
  end
end
