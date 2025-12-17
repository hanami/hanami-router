# frozen_string_literal: true

require "rack/head"

RSpec.describe Hanami::Router do
  describe "#scope" do
    let(:app) { Rack::MockRequest.new(router) }

    it "recognizes get path" do
      router = described_class.new do
        scope "trees" do
          root               to: ->(*) { [200, {}, ["Trees (GET)!"]] }
          get     "/cherry", to: ->(*) { [200, {}, ["Cherry (GET)!"]] }
          post    "/cherry", to: ->(*) { [200, {}, ["Cherry (POST)!"]] }
          put     "/cherry", to: ->(*) { [200, {}, ["Cherry (PUT)!"]] }
          patch   "/cherry", to: ->(*) { [200, {}, ["Cherry (PATCH)!"]] }
          delete  "/cherry", to: ->(*) { [200, {}, ["Cherry (DELETE)!"]] }
          trace   "/cherry", to: ->(*) { [200, {}, ["Cherry (TRACE)!"]] }
          options "/cherry", to: ->(*) { [200, {}, ["Cherry (OPTIONS)!"]] }
        end
      end

      app = Rack::MockRequest.new(router)

      expect(app.request("GET", "/trees", lint: true).body).to eq("Trees (GET)!")
      expect(app.request("GET", "/trees/cherry", lint: true).body).to eq("Cherry (GET)!")
      expect(app.request("POST", "/trees/cherry", lint: true).body).to eq("Cherry (POST)!")
      expect(app.request("PUT", "/trees/cherry", lint: true).body).to eq("Cherry (PUT)!")
      expect(app.request("PATCH", "/trees/cherry", lint: true).body).to eq("Cherry (PATCH)!")
      expect(app.request("DELETE", "/trees/cherry", lint: true).body).to eq("Cherry (DELETE)!")
      expect(app.request("TRACE", "/trees/cherry", lint: true).body).to eq("Cherry (TRACE)!")
      expect(app.request("OPTIONS", "/trees/cherry", lint: true).body).to eq("Cherry (OPTIONS)!")
    end

    it "allows trailing slash" do
      router = described_class.new do
        scope "trees/" do
          root to: ->(*) { [200, {}, ["Trees (GET)!"]] }
        end
      end

      app = Rack::MockRequest.new(router)

      expect(app.request("GET", "/trees/", lint: true).body).to eq("Trees (GET)!")
    end

    it "allows interpolation" do
      router = described_class.new do
        scope ":locale" do
          root to: ->(env) { [200, {}, ["Root (#{env.dig('router.params', :locale)})!"]] }

          get "/trees", to: ->(env) { [200, {}, ["Trees (#{env.dig('router.params', :locale)})!"]] }

          mount ->(env) { [200, {}, ["#{env["SCRIPT_NAME"]}, #{env["PATH_INFO"]}"]] }, at: "/mount"
        end
      end

      app = Rack::MockRequest.new(router)

      expect(app.request("GET", "/it", lint: true).body).to eq("Root (it)!")
      expect(app.request("GET", "/it/trees", lint: true).body).to eq("Trees (it)!")
      expect(app.request("GET", "/it/mount/foo", lint: true).body).to eq "/it/mount, /foo"
    end

    context "nested" do
      it "defines HTTP methods correctly" do
        router = described_class.new do
          scope "animals" do
            scope "mammals" do
              get "/cats", to: ->(*) { [200, {}, ["Meow!"]] }
            end
          end
        end

        app = Rack::MockRequest.new(router)

        expect(app.request("GET", "/animals/mammals/cats", lint: true).body).to eq("Meow!")
      end

      it "defines #redirect correctly" do
        router = described_class.new do
          scope "users" do
            scope "settings" do
              redirect "/image", to: "/avatar"
            end
          end
        end

        app = Rack::MockRequest.new(router)

        expect(app.request("GET", "users/settings/image", lint: true).headers["Location"]).to eq("/users/settings/avatar")
      end
    end

    context "redirect" do
      let(:router) do
        described_class.new do
          scope "users" do
            get "/home", to: ->(*) { [200, {}, ["New Home!"]] }
            redirect "/dashboard", to: "/home"
          end
        end
      end

      it "recognizes get path" do
        expect(app.request("GET", "/users/dashboard", lint: true).headers["Location"]).to eq("/users/home")
        expect(app.request("GET", "/users/dashboard", lint: true).status).to eq(301)
      end
    end

    describe "mount" do
      let(:router) do
        described_class.new do
          scope "api" do
            mount Backend::App, at: "/backend"
          end
        end
      end

      RSpec::Support::HTTP.mountable_verbs.each do |verb|
        it "accepts #{verb} for a scoped mount" do
          expect(app.request(verb.upcase, "/api/backend", lint: true).body).to eq(body_for("home", verb))
        end
      end

      context "HEAD" do
        let(:app) { Rack::MockRequest.new(Rack::Head.new(router)) }

        it "accepts head for a scoped mount" do
          expect(app.request("HEAD", "/api/backend", lint: true).body).to eq(body_for("home", "head"))
        end
      end
    end
  end
end
