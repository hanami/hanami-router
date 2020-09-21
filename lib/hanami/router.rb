# frozen_string_literal: true

require "rack/utils"

module Hanami
  # Rack compatible, lightweight and fast HTTP Router.
  #
  # @since 0.1.0
  class Router
    require "hanami/router/version"
    require "hanami/router/error"
    require "hanami/router/segment"
    require "hanami/router/redirect"
    require "hanami/router/prefix"
    require "hanami/router/params"
    require "hanami/router/trie"
    require "hanami/router/block"
    require "hanami/router/url_helpers"

    # URL helpers for other Hanami integrations
    #
    # @api private
    # @since 2.0.0
    attr_reader :url_helpers

    # Returns the given block as it is.
    #
    # @param blk [Proc] a set of route definitions
    #
    # @return [Proc] the given block
    #
    # @since 0.5.0
    #
    # @example
    #   # apps/web/config/routes.rb
    #   Hanami::Router.define do
    #     get "/", to: ->(*) { ... }
    #   end
    def self.define(&blk)
      blk
    end

    # Initialize the router
    #
    # @param base_url [String] the base URL where the HTTP application is
    #   deployed
    # @param prefix [String] the relative URL prefix where the HTTP application
    #   is deployed
    # @param resolver [#call(path, to)] a resolver for route entpoints
    # @param block_context [Hanami::Router::Block::Context)
    # @param not_found [#call(env)] default handler when route is not matched
    # @param blk [Proc] the route definitions
    #
    # @since 0.1.0
    #
    # @return [Hanami::Router]
    #
    # @example Base usage
    #   require "hanami/router"
    #
    #   Hanami::Router.new do
    #     get "/", to: ->(*) { [200, {}, ["OK"]] }
    #   end
    def initialize(base_url: DEFAULT_BASE_URL, prefix: DEFAULT_PREFIX, resolver: DEFAULT_RESOLVER, not_found: NOT_FOUND, block_context: nil, &blk) # rubocop:disable Layout/LineLength
      # TODO: verify if Prefix can handle both name and path prefix
      @path_prefix = Prefix.new(prefix)
      @name_prefix = Prefix.new("")
      @url_helpers = UrlHelpers.new(base_url)
      @resolver = resolver
      @not_found = not_found
      @block_context = block_context
      @fixed = {}
      @variable = {}
      @globbed = {}
      @mounted = {}
      instance_eval(&blk) if blk
    end

    # Resolve the given Rack env to a registered endpoint and invokes it.
    #
    # @param env [Hash] a Rack env
    #
    # @return [Array] a finalized Rack env response
    #
    # @since 0.1.0
    def call(env)
      endpoint, params = lookup(env)

      unless endpoint
        return not_allowed(env) ||
               not_found(env)
      end

      endpoint.call(
        _params(env, params)
      ).to_a
    end

    # Defines a named root route (a GET route for "/")
    #
    # @param to [#call] the Rack endpoint
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.7.0
    #
    # @see #get
    # @see #path
    # @see #url
    #
    # @example Proc endpoint
    #   require "hanami/router"
    #
    #   router = Hanami::Router.new do
    #     root to: ->(env) { [200, {}, ["Hello from Hanami!"]] }
    #   end
    #
    # @example Block endpoint
    #   require "hanami/router"
    #
    #   router = Hanami::Router.new do
    #     root do
    #       "Hello from Hanami!"
    #     end
    #   end
    #
    # @example URL helpers
    #   require "hanami/router"
    #
    #   router = Hanami::Router.new(base_url: "https://hanamirb.org") do
    #     root do
    #       "Hello from Hanami!"
    #     end
    #   end
    #
    #   router.path(:root) # => "/"
    #   router.url(:root)  # => "https://hanamirb.org"
    def root(to: nil, &blk)
      get("/", to: to, as: :root, &blk)
    end

    # Defines a route that accepts GET requests for the given path.
    # It also defines a route to accept HEAD requests.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param constraints [Hash] a set of constraints for path variables
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.1.0
    #
    # @see #initialize
    # @see #path
    # @see #url
    #
    # @example Proc endpoint
    #   require "hanami/router"
    #
    #   Hanami::Router.new do
    #     get "/", to: ->(*) { [200, {}, ["OK"]] }
    #   end
    #
    # @example Block endpoint
    #   require "hanami/router"
    #
    #   Hanami::Router.new do
    #     get "/" do
    #       "OK"
    #     end
    #   end
    #
    # @example Named route
    #   require "hanami/router"
    #
    #   router = Hanami::Router.new do
    #     get "/", to: ->(*) { [200, {}, ["OK"]] }, as: :welcome
    #   end
    #
    #   router.path(:welcome) # => "/"
    #   router.url(:welcome)  # => "http://localhost/"
    #
    # @example Constraints
    #   require "hanami/router"
    #
    #   Hanami::Router.new do
    #     get "/users/:id", to: ->(*) { [200, {}, ["OK"]] }, id: /\d+/
    #   end
    def get(path, to: nil, as: nil, **constraints, &blk)
      add_route("GET", path, to, as, constraints, &blk)
      add_route("HEAD", path, to, as, constraints, &blk)
    end

    # Defines a route that accepts POST requests for the given path.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param constraints [Hash] a set of constraints for path variables
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.1.0
    #
    # @see #get
    # @see #initialize
    # @see #path
    # @see #url
    def post(path, to: nil, as: nil, **constraints, &blk)
      add_route("POST", path, to, as, constraints, &blk)
    end

    # Defines a route that accepts PATCH requests for the given path.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param constraints [Hash] a set of constraints for path variables
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.1.0
    #
    # @see #get
    # @see #initialize
    # @see #path
    # @see #url
    def patch(path, to: nil, as: nil, **constraints, &blk)
      add_route("PATCH", path, to, as, constraints, &blk)
    end

    # Defines a route that accepts PUT requests for the given path.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param constraints [Hash] a set of constraints for path variables
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.1.0
    #
    # @see #get
    # @see #initialize
    # @see #path
    # @see #url
    def put(path, to: nil, as: nil, **constraints, &blk)
      add_route("PUT", path, to, as, constraints, &blk)
    end

    # Defines a route that accepts DELETE requests for the given path.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param constraints [Hash] a set of constraints for path variables
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.1.0
    #
    # @see #get
    # @see #initialize
    # @see #path
    # @see #url
    def delete(path, to: nil, as: nil, **constraints, &blk)
      add_route("DELETE", path, to, as, constraints, &blk)
    end

    # Defines a route that accepts TRACE requests for the given path.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param constraints [Hash] a set of constraints for path variables
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.1.0
    #
    # @see #get
    # @see #initialize
    # @see #path
    # @see #url
    def trace(path, to: nil, as: nil, **constraints, &blk)
      add_route("TRACE", path, to, as, constraints, &blk)
    end

    # Defines a route that accepts OPTIONS requests for the given path.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param constraints [Hash] a set of constraints for path variables
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.1.0
    #
    # @see #get
    # @see #initialize
    # @see #path
    # @see #url
    def options(path, to: nil, as: nil, **constraints, &blk)
      add_route("OPTIONS", path, to, as, constraints, &blk)
    end

    # Defines a route that accepts LINK requests for the given path.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param constraints [Hash] a set of constraints for path variables
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.1.0
    #
    # @see #get
    # @see #initialize
    # @see #path
    # @see #url
    def link(path, to: nil, as: nil, **constraints, &blk)
      add_route("LINK", path, to, as, constraints, &blk)
    end

    # Defines a route that accepts UNLINK requests for the given path.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param constraints [Hash] a set of constraints for path variables
    # @param blk [Proc] the anonymous proc to be used as endpoint for the route
    #
    # @since 0.1.0
    #
    # @see #get
    # @see #initialize
    # @see #path
    # @see #url
    def unlink(path, to: nil, as: nil, **constraints, &blk)
      add_route("UNLINK", path, to, as, constraints, &blk)
    end

    # Defines a route that redirects the incoming request to another path.
    #
    # @param path [String] the relative URL to be matched
    # @param to [#call] the Rack endpoint
    # @param as [Symbol] a unique name for the route
    # @param code [Integer] a HTTP status code to use for the redirect
    #
    # @since 0.1.0
    #
    # @see #get
    # @see #initialize
    def redirect(path, to: nil, as: nil, code: DEFAULT_REDIRECT_CODE)
      get(path, to: _redirect(to, code), as: as)
    end

    # Defines a routing scope. Routes defined in the context of a scope,
    # inherit the given path as path prefix and as a named routes prefix.
    #
    # @param path [String] the scope path to be used as a path prefix
    # @param blk [Proc] the routes definitions withing the scope
    #
    # @since 2.0.0
    #
    # @see #path
    #
    # @example
    #   require "hanami/router"
    #
    #   router = Hanami::Router.new do
    #     scope "v1" do
    #       get "/users", to: ->(*) { ... }, as: :users
    #     end
    #   end
    #
    #   router.path(:v1_users) # => "/v1/users"
    def scope(path, &blk)
      path_prefix = @path_prefix
      name_prefix = @name_prefix

      begin
        @path_prefix = @path_prefix.join(path.to_s)
        @name_prefix = @name_prefix.join(path.to_s)
        instance_eval(&blk)
      ensure
        @path_prefix = path_prefix
        @name_prefix = name_prefix
      end
    end

    # Mount a Rack application at the specified path.
    # All the requests starting with the specified path, will be forwarded to
    # the given application.
    #
    # All the other methods (eg `#get`) support callable objects, but they
    # restrict the range of the acceptable HTTP verb. Mounting an application
    # with #mount doesn't apply this kind of restriction at the router level,
    # but let the application to decide.
    #
    # @param app [#call] a class or an object that responds to #call
    # @param at [String] the relative path where to mount the app
    # @param constraints [Hash] a set of constraints for path variables
    #
    # @since 0.1.1
    #
    # @example
    #   require "hanami/router"
    #
    #   Hanami::Router.new do
    #     mount MyRackApp.new, at: "/foo"
    #   end
    def mount(app, at:, **constraints)
      path = prefixed_path(at)
      prefix = Segment.fabricate(path, **constraints)
      @mounted[prefix] = @resolver.call(path, app)
    end

    # Generate an relative URL for a specified named route.
    # The additional arguments will be used to compose the relative URL - in
    #   case it has tokens to match - and for compose the query string.
    #
    # @param name [Symbol] the route name
    #
    # @return [String]
    #
    # @raise [Hanami::Routing::InvalidRouteException] when the router fails to
    #   recognize a route, because of the given arguments.
    #
    # @since 0.1.0
    #
    # @see #url
    #
    # @example
    #   require "hanami/router"
    #
    #   router = Hanami::Router.new(base_url: "https://hanamirb.org") do
    #     get "/login", to: ->(*) { ... }, as: :login
    #     get "/:name", to: ->(*) { ... }, as: :framework
    #   end
    #
    #   router.path(:login)                          # => "/login"
    #   router.path(:login, return_to: "/dashboard") # => "/login?return_to=%2Fdashboard"
    #   router.path(:framework, name: "router")      # => "/router"
    def path(name, variables = {})
      @url_helpers.path(name, variables)
    end

    # Generate an absolute URL for a specified named route.
    # The additional arguments will be used to compose the relative URL - in
    #   case it has tokens to match - and for compose the query string.
    #
    # @param name [Symbol] the route name
    #
    # @return [String]
    #
    # @raise [Hanami::Routing::InvalidRouteException] when the router fails to
    #   recognize a route, because of the given arguments.
    #
    # @since 0.1.0
    #
    # @see #path
    #
    # @example
    #   require "hanami/router"
    #
    #   router = Hanami::Router.new(base_url: "https://hanamirb.org") do
    #     get "/login", to: ->(*) { ... }, as: :login
    #     get "/:name", to: ->(*) { ... }, as: :framework
    #   end
    #
    #   router.url(:login)                          # => "https://hanamirb.org/login"
    #   router.url(:login, return_to: "/dashboard") # => "https://hanamirb.org/login?return_to=%2Fdashboard"
    #   router.url(:framework, name: "router")      # => "https://hanamirb.org/router"
    def url(name, variables = {})
      @url_helpers.url(name, variables)
    end

    # Recognize the given env, path, or name and return a route for testing
    # inspection.
    #
    # If the route cannot be recognized, it still returns an object for testing
    # inspection.
    #
    # @param env [Hash, String, Symbol] Rack env, path or route name
    # @param options [Hash] a set of options for Rack env or route params
    # @param params [Hash] a set of params
    #
    # @return [Hanami::Routing::RecognizedRoute] the recognized route
    #
    # @since 0.5.0
    #
    # @see Hanami::Router#env_for
    # @see Hanami::Routing::RecognizedRoute
    #
    # @example Successful Path Recognition
    #   require "hanami/router"
    #
    #   router = Hanami::Router.new do
    #     get "/books/:id", to: ->(*) { ... }, as: :book
    #   end
    #
    #   route = router.recognize("/books/23")
    #   route.verb      # => "GET" (default)
    #   route.routable? # => true
    #   route.params    # => {:id=>"23"}
    #
    # @example Successful Rack Env Recognition
    #   require "hanami/router"
    #
    #   router = Hanami::Router.new do
    #     get "/books/:id", to: ->(*) { ... }, as: :book
    #   end
    #
    #   route = router.recognize(Rack::MockRequest.env_for("/books/23"))
    #   route.verb      # => "GET" (default)
    #   route.routable? # => true
    #   route.params    # => {:id=>"23"}
    #
    # @example Successful Named Route Recognition
    #   require "hanami/router"
    #
    #   router = Hanami::Router.new do
    #     get "/books/:id", to: ->(*) { ... }, as: :book
    #   end
    #
    #   route = router.recognize(:book, id: 23)
    #   route.verb      # => "GET" (default)
    #   route.routable? # => true
    #   route.params    # => {:id=>"23"}
    #
    # @example Failing Recognition For Unknown Path
    #   require "hanami/router"
    #
    #   router = Hanami::Router.new do
    #     get "/books/:id", to: ->(*) { ... }, as: :book
    #   end
    #
    #   route = router.recognize("/books")
    #   route.verb      # => "GET" (default)
    #   route.routable? # => false
    #
    # @example Failing Recognition For Path With Wrong HTTP Verb
    #   require "hanami/router"
    #
    #   router = Hanami::Router.new do
    #     get "/books/:id", to: ->(*) { ... }, as: :book
    #   end
    #
    #   route = router.recognize("/books/23", method: :post)
    #   route.verb      # => "POST"
    #   route.routable? # => false
    #
    # @example Failing Recognition For Rack Env With Wrong HTTP Verb
    #   require "hanami/router"
    #
    #   router = Hanami::Router.new do
    #     get "/books/:id", to: ->(*) { ... }, as: :book
    #   end
    #
    #   route = router.recognize(Rack::MockRequest.env_for("/books/23", method: :post))
    #   route.verb      # => "POST"
    #   route.routable? # => false
    #
    # @example Failing Recognition Named Route With Wrong Params
    #   require "hanami/router"
    #
    #   router = Hanami::Router.new do
    #     get "/books/:id", to: ->(*) { ... }, as: :book
    #   end
    #
    #   route = router.recognize(:book)
    #   route.verb      # => "GET" (default)
    #   route.routable? # => false
    #
    # @example Failing Recognition Named Route With Wrong HTTP Verb
    #   require "hanami/router"
    #
    #   router = Hanami::Router.new do
    #     get "/books/:id", to: ->(*) { ... }, as: :book
    #   end
    #
    #   route = router.recognize(:book, {method: :post}, {id: 1})
    #   route.verb      # => "POST"
    #   route.routable? # => false
    #   route.params    # => {:id=>"1"}
    def recognize(env, params = {}, options = {})
      require "hanami/router/recognized_route"
      env = env_for(env, params, options)
      endpoint, params = lookup(env)

      RecognizedRoute.new(
        endpoint, _params(env, params)
      )
    end

    # @since 2.0.0
    # @api private
    def fixed(env)
      @fixed.dig(env["REQUEST_METHOD"], env["PATH_INFO"])
    end

    # @since 2.0.0
    # @api private
    def variable(env)
      @variable[env["REQUEST_METHOD"]]&.find(env["PATH_INFO"])
    end

    # @since 2.0.0
    # @api private
    def globbed(env)
      @globbed[env["REQUEST_METHOD"]]&.each do |path, to|
        if (match = path.match(env["PATH_INFO"]))
          return [to, match.named_captures]
        end
      end

      nil
    end

    # @since 2.0.0
    # @api private
    def mounted(env)
      @mounted.each do |prefix, app|
        next unless (match = prefix.peek_match(env["PATH_INFO"]))

        # TODO: ensure compatibility with existing env["SCRIPT_NAME"]
        # TODO: cleanup this code
        env["SCRIPT_NAME"] = env["SCRIPT_NAME"].to_s + prefix.to_s
        env["PATH_INFO"] = env["PATH_INFO"].sub(prefix.to_s, "")
        env["PATH_INFO"] = "/" if env["PATH_INFO"] == ""

        return [app, match.named_captures]
      end

      nil
    end

    # @since 2.0.0
    # @api private
    def not_allowed(env)
      (_not_allowed_fixed(env) ||
       _not_allowed_variable(env)) and return [405, {"Content-Length" => "11"}, ["Not Allowed"]]
    end

    # @since 2.0.0
    # @api private
    def not_found(env)
      @not_found.call(env)
    end

    protected

    # Fabricate Rack env for the given Rack env, path or named route
    #
    # @param env [Hash, String, Symbol] Rack env, path or route name
    # @param options [Hash] a set of options for Rack env or route params
    # @param params [Hash] a set of params
    #
    # @return [Hash] Rack env
    #
    # @since 0.5.0
    # @api private
    #
    # @see Hanami::Router#recognize
    # @see http://www.rubydoc.info/github/rack/rack/Rack%2FMockRequest.env_for
    def env_for(env, params = {}, options = {})
      require "rack/mock"

      case env
      when ::String
        ::Rack::MockRequest.env_for(env, options)
      when ::Symbol
        begin
          url = path(env, params)
          return env_for(url, params, options) # rubocop:disable Style/RedundantReturn
        rescue Hanami::Router::InvalidRouteException
          {} # Empty Rack env
        end
      else
        env
      end
    end

    private

    # @since 2.0.0
    # @api private
    DEFAULT_BASE_URL = "http://localhost"

    # @since 2.0.0
    # @api private
    DEFAULT_PREFIX = "/"

    # @since 2.0.0
    # @api private
    DEFAULT_RESOLVER = ->(_, to) { to }

    # @since 2.0.0
    # @api private
    DEFAULT_REDIRECT_CODE = 301

    # @since 2.0.0
    # @api private
    PARAMS = "router.params"

    # Default response when no route was matched
    #
    # @api private
    # @since 2.0.0
    NOT_FOUND = ->(*) { [404, {"Content-Length" => "9"}, ["Not Found"]] }.freeze

    # @since 2.0.0
    # @api private
    def lookup(env)
      endpoint = fixed(env)
      return [endpoint, {}] if endpoint

      variable(env) || globbed(env) || mounted(env)
    end

    # @since 2.0.0
    # @api private
    def add_route(http_method, path, to, as, constraints, &blk)
      path = prefixed_path(path)
      to = resolve_endpoint(path, to, blk)

      if globbed?(path)
        add_globbed_route(http_method, path, to, constraints)
      elsif variable?(path)
        add_variable_route(http_method, path, to, constraints)
      else
        add_fixed_route(http_method, path, to)
      end

      add_named_route(path, as, constraints) if as
    end

    # @since 2.0.0
    # @api private
    def resolve_endpoint(path, to, blk)
      (to || blk) or raise MissingEndpointError.new(path)
      to = Block.new(@block_context, blk) if to.nil?

      @resolver.call(path, to)
    end

    # @since 2.0.0
    # @api private
    def add_globbed_route(http_method, path, to, constraints)
      @globbed[http_method] ||= []
      @globbed[http_method] << [Segment.fabricate(path, **constraints), to]
    end

    # @since 2.0.0
    # @api private
    def add_variable_route(http_method, path, to, constraints)
      @variable[http_method] ||= Trie.new
      @variable[http_method].add(path, to, constraints)
    end

    # @since 2.0.0
    # @api private
    def add_fixed_route(http_method, path, to)
      @fixed[http_method] ||= {}
      @fixed[http_method][path] = to
    end

    # @since 2.0.0
    # @api private
    def add_named_route(path, as, constraints)
      @url_helpers.add(prefixed_name(as), Segment.fabricate(path, **constraints))
    end

    # @since 2.0.0
    # @api private
    def variable?(path)
      /:/.match?(path)
    end

    # @since 2.0.0
    # @api private
    def globbed?(path)
      /\*/.match?(path)
    end

    # @since 2.0.0
    # @api private
    def prefixed_path(path)
      @path_prefix.join(path).to_s
    end

    # @since 2.0.0
    # @api private
    def prefixed_name(name)
      @name_prefix.relative_join(name, "_").to_sym
    end

    # @since 2.0.0
    # @api private
    def _redirect(to, code)
      body = Rack::Utils::HTTP_STATUS_CODES.fetch(code) do
        raise UnknownHTTPStatusCodeError.new(code)
      end

      destination = prefixed_path(to)
      Redirect.new(destination, ->(*) { [code, {"Location" => destination}, [body]] })
    end

    # @since 2.0.0
    # @api private
    def _params(env, params)
      params ||= {}
      env[PARAMS] ||= {}
      env[PARAMS].merge!(Rack::Utils.parse_nested_query(env["QUERY_STRING"]))
      env[PARAMS].merge!(params)
      env[PARAMS] = Params.deep_symbolize(env[PARAMS])
      env
    end

    # @since 2.0.0
    # @api private
    def _not_allowed_fixed(env)
      found = false

      @fixed.each_value do |routes|
        break if found

        found = routes.key?(env["PATH_INFO"])
      end

      found
    end

    # @since 2.0.0
    # @api private
    def _not_allowed_variable(env)
      found = false

      @variable.each_value do |routes|
        break if found

        found = routes.find(env["PATH_INFO"])
      end

      found
    end
  end
end
