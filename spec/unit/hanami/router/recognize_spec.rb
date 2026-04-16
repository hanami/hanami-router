# frozen_string_literal: true

RSpec.describe Hanami::Router do
  describe "#recognize" do
    let(:router) do
      configuration = Action::Configuration.new("recognize")

      Hanami::Router.new do
        get "/",              to: ->(*) { [200, {}, ["HOME"]] },                                        as: :home
        get "/dashboard",     to: Web::Controllers::Dashboard::Index.new(configuration: configuration), as: :dashboard
        get "/rack_class",    to: RackMiddleware,                                                       as: :rack_class
        get "/rack_app",      to: RackMiddlewareInstanceMethod.new,                                     as: :rack_app
        get "/proc",          to: ->(*) { [200, {}, ["OK"]] },                                          as: :proc
        get "/resources/:id", to: ->(*) { [200, {}, ["PARAMS"]] },                                      as: :params
        get "/missing",       to: "missing#index",                                                      as: :missing
        redirect "/home",     to: "/"
      end
    end

    context "from Rack env" do
      it "recognizes proc" do
        env   = Rack::MockRequest.env_for("/proc", method: :get)
        route = router.recognize(env)

        _, _, body = *route.call({})

        expect(body).to eq(["OK"])

        expect(route.routable?).to be(true)
        expect(route.redirect?).to be(false)
        expect(route.endpoint.inspect).to include("spec/unit/hanami/router/recognize_spec.rb:13 (lambda)")
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("GET")
        expect(route.path).to eq("/proc")
        expect(route.params).to eq({})
      end

      it "recognizes procs with params" do
        env   = Rack::MockRequest.env_for("/resources/1", method: :get)
        route = router.recognize(env)

        expect(route.routable?).to be(true)
        expect(route.redirect?).to be(false)
        expect(route.endpoint.inspect).to include("spec/unit/hanami/router/recognize_spec.rb:14 (lambda)")
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("GET")
        expect(route.path).to eq("/resources/1")
        expect(route.params).to eq(id: "1")
      end

      it "recognizes action from instance" do
        env   = Rack::MockRequest.env_for("/dashboard", method: :get)
        route = router.recognize(env)

        _, _, body = *route.call({})

        expect(body).to eq(["Hello from Web::Controllers::Dashboard::Index"])

        expect(route.routable?).to be(true)
        expect(route.redirect?).to be(false)
        # TODO: with the mixin that adds supports for actions, it's worth considering to add `#action` method
        expect(route.endpoint.class).to eq(Web::Controllers::Dashboard::Index)
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("GET")
        expect(route.path).to eq("/dashboard")
        expect(route.params).to eq({})
      end

      it "recognizes action from rack middleware class" do
        env   = Rack::MockRequest.env_for("/rack_class", method: :get)
        route = router.recognize(env)

        _, _, body = *route.call({})

        expect(body).to eq(["RackMiddleware"])

        expect(route.routable?).to be(true)
        expect(route.redirect?).to be(false)
        expect(route.endpoint).to eq(RackMiddleware)
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("GET")
        expect(route.path).to eq("/rack_class")
        expect(route.params).to eq({})
      end

      it "recognizes action from rack middleware" do
        env   = Rack::MockRequest.env_for("/rack_app", method: :get)
        route = router.recognize(env)

        _, _, body = *route.call({})

        expect(body).to eq(["RackMiddlewareInstanceMethod"])

        expect(route.routable?).to be(true)
        expect(route.redirect?).to be(false)
        expect(route.endpoint.class).to eq(RackMiddlewareInstanceMethod)
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("GET")
        expect(route.path).to eq("/rack_app")
        expect(route.params).to eq({})
      end

      it "recognizes action for redirect" do
        env   = Rack::MockRequest.env_for("/home", method: :get)
        route = router.recognize(env)

        _, headers, body = *route.call({})

        expect(body).to eq(["Moved Permanently"])
        expect(headers).to eq(rack_headers("Location" => "/"))

        expect(route.routable?).to be(true)
        expect(route.redirect?).to be(true)
        expect(route.endpoint).to be(nil)
        expect(route.redirection_path).to eq("/")
        expect(route.verb).to eq("GET")
        expect(route.path).to eq("/home")
        expect(route.params).to eq({})
      end

      it "returns not routeable result when cannot recognize" do
        env   = Rack::MockRequest.env_for("/", method: :post)
        route = router.recognize(env)

        expect(route.routable?).to be(false)
        expect(route.redirect?).to be(false)
        expect(route.endpoint).to be(nil)
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("POST")
        expect(route.path).to eq("/")
        expect(route.params).to eq({})
      end

      # TODO: Given LazyEnpoint is a concept that is tight to Endpoint resolution and we don't have
      # endpoint resolution anymore, is still worth to keep this concept around?
      xit "returns not routeable result when the lazy endpoint doesn't correspond to an action" do
        env   = Rack::MockRequest.env_for("/missing", method: :get)
        route = router.recognize(env)

        expect(route.routable?).to be(false)
        expect(route.redirect?).to be(false)
        expect(route.action).to be(nil)
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("GET")
        expect(route.path).to eq("/missing")
        expect(route.params).to eq({})
      end

      it "raises error if #call is invoked for not routeable object when cannot recognize" do
        env   = Rack::MockRequest.env_for("/", method: :post)
        route = router.recognize(env)

        expect { route.call(env) }.to raise_error(Hanami::Router::NotRoutableEndpointError, "Cannot find routable endpoint for: POST /")
      end
    end

    context "from path" do
      it "recognizes proc" do
        route = router.recognize("/proc")

        _, _, body = *route.call({})

        expect(body).to eq(["OK"])

        expect(route.routable?).to be(true)
        expect(route.redirect?).to be(false)
        expect(route.endpoint.inspect).to include("spec/unit/hanami/router/recognize_spec.rb:13 (lambda)")
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("GET")
        expect(route.path).to eq("/proc")
        expect(route.params).to eq({})
      end

      it "recognizes procs with params" do
        route = router.recognize("/resources/1")

        expect(route.routable?).to be(true)
        expect(route.redirect?).to be(false)
        expect(route.endpoint.inspect).to include("spec/unit/hanami/router/recognize_spec.rb:14 (lambda)")
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("GET")
        expect(route.path).to eq("/resources/1")
        expect(route.params).to eq(id: "1")
      end

      it "recognizes action from rack middleware class" do
        route = router.recognize("/rack_class")

        _, _, body = *route.call({})

        expect(body).to eq(["RackMiddleware"])

        expect(route.routable?).to be(true)
        expect(route.redirect?).to be(false)
        expect(route.endpoint).to eq(RackMiddleware)
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("GET")
        expect(route.path).to eq("/rack_class")
        expect(route.params).to eq({})
      end

      it "recognizes action from rack middleware" do
        route = router.recognize("/rack_app")

        _, _, body = *route.call({})

        expect(body).to eq(["RackMiddlewareInstanceMethod"])

        expect(route.routable?).to be(true)
        expect(route.redirect?).to be(false)
        expect(route.endpoint.class).to eq(RackMiddlewareInstanceMethod)
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("GET")
        expect(route.path).to eq("/rack_app")
        expect(route.params).to eq({})
      end

      it "recognizes redirect" do
        route = router.recognize("/home")

        _, headers, body = *route.call({})

        expect(body).to eq(["Moved Permanently"])
        expect(headers).to eq(rack_headers("Location" => "/"))

        expect(route.routable?).to be(true)
        expect(route.redirect?).to be(true)
        expect(route.endpoint).to be(nil)
        expect(route.redirection_path).to eq("/")
        expect(route.verb).to eq("GET")
        expect(route.path).to eq("/home")
        expect(route.params).to eq({})
      end

      it "returns not routeable result when cannot recognize" do
        route = router.recognize("/", method: :post)

        expect(route.routable?).to be(false)
        expect(route.redirect?).to be(false)
        expect(route.endpoint).to be(nil)
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("POST")
        expect(route.path).to eq("/")
        expect(route.params).to eq({})
      end

      # TODO: Given LazyEnpoint is a concept that is tight to Endpoint resolution and we don't have
      # endpoint resolution anymore, is still worth to keep this concept around?
      xit "returns not routeable result when the lazy endpoint doesn't correspond to an action" do
        route = router.recognize("/missing")

        expect(route.routable?).to be(false)
        expect(route.redirect?).to be(false)
        expect(route.action).to be(nil)
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("GET")
        expect(route.path).to eq("/missing")
        expect(route.params).to eq({})
      end

      it "raises error if #call is invoked for not routeable object when cannot recognize" do
        env   = Rack::MockRequest.env_for("/", method: :post)
        route = router.recognize("/", method: :post)

        expect { route.call(env) }.to raise_error(Hanami::Router::NotRoutableEndpointError, "Cannot find routable endpoint for: POST /")
      end

      it "raises error if #call is invoked for unknown path" do
        route = router.recognize("/unknown")

        expect(route.routable?).to be(false)
        expect(route.redirect?).to be(false)
        expect(route.endpoint).to be(nil)
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("GET")
        expect(route.path).to eq("/unknown")
        expect(route.params).to eq({})

        expect { route.call({}) }.to raise_error(Hanami::Router::NotRoutableEndpointError, "Cannot find routable endpoint for: GET /unknown")
      end
    end

    context "from named path" do
      it "recognizes proc" do
        route = router.recognize(:proc)

        _, _, body = *route.call({})

        expect(body).to eq(["OK"])

        expect(route.routable?).to be(true)
        expect(route.redirect?).to be(false)
        expect(route.endpoint.inspect).to include("spec/unit/hanami/router/recognize_spec.rb:13 (lambda)")
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("GET")
        expect(route.path).to eq("/proc")
        expect(route.params).to eq({})
      end

      it "recognizes procs with params" do
        route = router.recognize(:params, params: {id: 1})

        expect(route.routable?).to be(true)
        expect(route.redirect?).to be(false)
        expect(route.endpoint.inspect).to include("spec/unit/hanami/router/recognize_spec.rb:14 (lambda)")
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("GET")
        expect(route.path).to eq("/resources/1")
        expect(route.params).to eq(id: "1")
      end

      it "recognizes action from rack middleware class" do
        route = router.recognize(:rack_class)

        _, _, body = *route.call({})

        expect(body).to eq(["RackMiddleware"])

        expect(route.routable?).to be(true)
        expect(route.redirect?).to be(false)
        expect(route.endpoint).to eq(RackMiddleware)
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("GET")
        expect(route.path).to eq("/rack_class")
        expect(route.params).to eq({})
      end

      it "recognizes action from rack middleware" do
        route = router.recognize(:rack_app)

        _, _, body = *route.call({})

        expect(body).to eq(["RackMiddlewareInstanceMethod"])

        expect(route.routable?).to be(true)
        expect(route.redirect?).to be(false)
        expect(route.endpoint.class).to eq(RackMiddlewareInstanceMethod)
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("GET")
        expect(route.path).to eq("/rack_app")
        expect(route.params).to eq({})
      end

      it "returns not routeable result when cannot find named route" do
        route = router.recognize(:unknown)

        expect(route.routable?).to be(false)
        expect(route.redirect?).to be(false)
        expect(route.endpoint).to be(nil)
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to be(nil)
        expect(route.path).to be(nil)
        expect(route.params).to eq({})
      end

      it "returns not routeable result when cannot recognize" do
        route = router.recognize(:home, method: :post)

        expect(route.routable?).to be(false)
        expect(route.redirect?).to be(false)
        expect(route.endpoint).to be(nil)
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("POST")
        expect(route.path).to eq("/")
        expect(route.params).to eq({})
      end

      # TODO: Given LazyEnpoint is a concept that is tight to Endpoint resolution and we don't have
      # endpoint resolution anymore, is still worth to keep this concept around?
      xit "returns not routeable result when the lazy endpoint doesn't correspond to an action" do
        route = router.recognize(:missing)

        expect(route.routable?).to be(false)
        expect(route.redirect?).to be(false)
        expect(route.endpoint).to be(nil)
        expect(route.redirection_path).to be(nil)
        expect(route.verb).to eq("GET")
        expect(route.path).to eq("/missing")
        expect(route.params).to eq({})
      end

      it "raises error if #call is invoked for not routeable object when cannot recognize" do
        env   = Rack::MockRequest.env_for("/", method: :post)
        route = router.recognize(:home, method: :post)

        expect { route.call(env) }.to raise_error(Hanami::Router::NotRoutableEndpointError, "Cannot find routable endpoint for: POST /")
      end
    end

    # See: https://github.com/hanami/hanami-router/issues/271
    context "when forwarding method: kwarg to env_for" do
      let(:router) do
        Hanami::Router.new do
          get    "/images",      to: ->(*) { [200, {}, ["INDEX"]] }
          post   "/images",      to: ->(*) { [200, {}, ["UPLOAD"]] }
          get    "/images/:id",  to: ->(*) { [200, {}, ["SHOW"]] }
          post   "/images/bulk", to: ->(*) { [200, {}, ["BULK"]] }
          put    "/images/:id",  to: ->(*) { [200, {}, ["REPLACE"]] }, as: :replace
        end
      end

      it "recognizes a POST route by path" do
        route = router.recognize("/images/bulk", method: "POST")

        expect(route.routable?).to be(true)
        expect(route.verb).to eq("POST")
        expect(route.path).to eq("/images/bulk")
        expect(route.params).to eq({})
      end

      it "accepts a symbol method value" do
        route = router.recognize("/images", method: :post)

        expect(route.routable?).to be(true)
        expect(route.verb).to eq("POST")
        expect(route.path).to eq("/images")
      end

      it "recognizes a PUT route with path variables" do
        route = router.recognize("/images/1", method: :put)

        expect(route.routable?).to be(true)
        expect(route.verb).to eq("PUT")
        expect(route.path).to eq("/images/1")
        expect(route.params).to eq(id: "1")
      end

      it "recognizes a named route with params and method" do
        route = router.recognize(:replace, params: {id: 1}, method: :put)

        expect(route.routable?).to be(true)
        expect(route.verb).to eq("PUT")
        expect(route.path).to eq("/images/1")
        expect(route.params).to eq(id: "1")
      end
    end
  end
end
