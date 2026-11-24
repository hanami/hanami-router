# frozen_string_literal: true

RSpec.describe Hanami::Router do
  describe "#scope with constraints" do
    let(:app) { Rack::MockRequest.new(router) }
    let(:endpoint) { ->(env) { [200, {}, [env["router.params"].inspect]] } }

    def status(verb, path)
      app.request(verb, path).status
    end

    context "a variable route in the block" do
      let(:router) do
        e = endpoint
        described_class.new do
          scope "/:locale", locale: /en|it/ do
            get "/flowers", to: e
          end
        end
      end

      it "matches an allowed value" do
        response = app.request("GET", "/en/flowers", lint: true)

        expect(response.status).to eq(200)
        expect(response.body).to eq({locale: "en"}.inspect)
      end

      it "does not match a disallowed value" do
        expect(status("GET", "/fr/flowers")).to eq(404)
      end
    end

    context "root in the block" do
      let(:router) do
        e = endpoint
        described_class.new do
          scope "/:locale", locale: /en|it/ do
            root to: e
          end
        end
      end

      it "honours the constraint" do
        expect(status("GET", "/it")).to eq(200)
        expect(status("GET", "/fr")).to eq(404)
      end
    end

    context "every HTTP verb helper" do
      verbs = %w[GET HEAD POST PUT PATCH DELETE TRACE OPTIONS LINK UNLINK]

      let(:router) do
        e = endpoint
        described_class.new do
          scope "/:locale", locale: /en|it/ do
            get     "/things", to: e
            post    "/things", to: e
            put     "/things", to: e
            patch   "/things", to: e
            delete  "/things", to: e
            trace   "/things", to: e
            options "/things", to: e
            link    "/things", to: e
            unlink  "/things", to: e
          end
        end
      end

      it "applies the constraint to each of them" do
        verbs.each do |verb|
          expect(status(verb, "/en/things")).to eq(200), verb
          expect(status(verb, "/fr/things")).to eq(404), verb
        end
      end
    end

    context "nested scopes" do
      let(:router) do
        e = endpoint
        described_class.new do
          scope "/:locale", locale: /en|it/ do
            scope "/:year", year: /\d{4}/ do
              get "/flowers", to: e
            end
          end
        end
      end

      it "applies both scopes' constraints" do
        expect(status("GET", "/en/2026/flowers")).to eq(200)
        expect(status("GET", "/fr/2026/flowers")).to eq(404)
        expect(status("GET", "/en/latest/flowers")).to eq(404)
        expect(router.routes.first.constraints).to eq(locale: /en|it/, year: /\d{4}/)
      end
    end

    context "the same key at more than one level" do
      let(:router) do
        e = endpoint
        described_class.new do
          scope "/:locale", locale: /en|it/ do
            get "/flowers", to: e

            scope "/garden", locale: /it/ do
              get "/flowers", to: e
            end

            get "/places", to: e, locale: /fr/
          end
        end
      end

      it "uses an inner scope's value over the outer one" do
        expect(status("GET", "/it/garden/flowers")).to eq(200)
        expect(status("GET", "/en/garden/flowers")).to eq(404)
      end

      it "uses a route's own value over the scope's" do
        expect(status("GET", "/fr/places")).to eq(200)
        expect(status("GET", "/en/places")).to eq(404)
      end

      it "restores the outer scope's constraints after an inner scope" do
        expect(status("GET", "/en/flowers")).to eq(200)
      end
    end

    context "routes after the block" do
      it "are not constrained" do
        e = endpoint
        router = described_class.new do
          scope "/:locale", locale: /en|it/ do
            get "/flowers", to: e
          end

          get "/:locale/places", to: e
        end

        app = Rack::MockRequest.new(router)

        expect(app.request("GET", "/fr/places").status).to eq(200)
        expect(router.routes.last.constraints).to eq({})
      end

      it "are not constrained when the block raises" do
        e = endpoint
        router = described_class.new

        expect {
          router.scope("/:locale", locale: /en|it/) { raise "boom" }
        }.to raise_error(RuntimeError, "boom")

        router.get "/:locale/places", to: e
        app = Rack::MockRequest.new(router)

        expect(app.request("GET", "/fr/places").status).to eq(200)
      end
    end

    context "constraints for segments a route doesn't have" do
      let(:router) do
        e = endpoint
        described_class.new do
          scope "/info", locale: /en|it/ do
            get "/about", to: e
            get "/pages/:slug", to: e
          end
        end
      end

      it "are ignored by fixed routes" do
        expect(status("GET", "/info/about")).to eq(200)
      end

      it "are ignored by variable routes" do
        expect(status("GET", "/info/pages/contact")).to eq(200)
      end
    end

    context "a globbed route in the block" do
      let(:router) do
        e = endpoint
        described_class.new do
          scope "/:locale", locale: /en|it/ do
            get "/files/*path", to: e
          end
        end
      end

      it "honours the constraint" do
        expect(status("GET", "/en/files/a/b")).to eq(200)
        expect(status("GET", "/fr/files/a/b")).to eq(404)
      end
    end

    context "a mount in the block" do
      let(:router) do
        mounted = ->(env) { [200, {}, ["#{env['SCRIPT_NAME']}, #{env['PATH_INFO']}"]] }
        described_class.new do
          scope "/:locale", locale: /en|it/ do
            mount mounted, at: "/api"
          end
        end
      end

      it "honours the constraint" do
        response = app.request("GET", "/en/api/flowers", lint: true)

        expect(response.status).to eq(200)
        expect(response.body).to eq("/en/api, /flowers")
        expect(status("GET", "/fr/api/flowers")).to eq(404)
        expect(router.routes.first.constraints).to eq(locale: /en|it/)
      end
    end

    context "named routes" do
      let(:router) do
        e = endpoint
        described_class.new do
          scope "/:locale", as: :locale, locale: /en|it/ do
            get "/", to: e, as: :home
            get "/flowers/:id", to: e, as: :flower, id: /\d+/
          end
        end
      end

      it "generates paths" do
        expect(router.path(:locale_home, locale: "en")).to eq("/en")
        expect(router.path(:locale_flower, locale: "it", id: "1")).to eq("/it/flowers/1")
      end
    end

    context "inspection" do
      let(:router) do
        e = endpoint
        described_class.new do
          scope "/:locale", as: :locale, locale: /en|it/ do
            get "/flowers/:id", to: e, as: :flower, id: /\d+/
          end
        end
      end

      it "shows the merged constraints" do
        expect(router.routes.first.constraints).to eq(locale: /en|it/, id: /\d+/)

        output = Hanami::Router::Formatter::HumanFriendly.new.call(router.routes)

        expect(output).to include("locale: /en|it/")
        expect(output).to include("id: /\\d+/")
      end
    end
  end
end
