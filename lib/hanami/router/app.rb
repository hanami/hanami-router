# frozen_string_literal: true

require "hanami/router"

module Hanami
  class Router
    # Hanami::Router::App
    #
    # A minimal, fast framework for building small apps and HTTP APIs on top of
    # {Hanami::Router}.
    #
    # @since 2.4.0
    class App
      require "hanami/router/app/error"
      require "hanami/router/app/router"
      require "hanami/router/app/middleware"
      require "hanami/router/app/dsl"

      # @since 2.4.0
      # @api private
      def self.inherited(app)
        super

        app.extend(DSL::ClassMethods)
        app.include(DSL::InstanceMethods)
      end

      # Defines helper methods available within the block context.
      # Helper methods have access to default utilities available in block
      # context (e.g. `#halt`).
      #
      # @param mod [Module] optional module to include in block context
      # @param blk [Proc] inline helper definitions
      #
      # @since 2.4.0
      #
      # @example Inline helpers definition
      #   require "hanami/router/app"
      #
      #   class MyApp < Hanami::Router::App
      #     helpers do
      #       def redirect_to_root
      #         # redirect method is provided by Hanami::Router::App block context
      #         redirect "/"
      #       end
      #     end
      #
      #     root { "Hello, World" }
      #
      #     get "/legacy" do
      #       redirect_to_root
      #     end
      #   end
      #
      # @example Module helpers definition
      #   require "hanami/router/app"
      #
      #   class MyApp < Hanami::Router::App
      #     module Authentication
      #       private
      #
      #       def unauthorized
      #         halt(401)
      #       end
      #     end
      #
      #     helpers(Authentication)
      #
      #     root { "Hello, World" }
      #
      #     get "/secrets" do
      #       unauthorized
      #     end
      #   end
      def self.helpers(mod = nil, &blk)
        const_get(:BlockContext).include(mod || Module.new(&blk))
      end

      # Defines a named root route (a GET route for "/")
      #
      # @param to [#call] the Rack endpoint
      # @param blk [Proc] the anonymous proc to be used as endpoint for the route
      #
      # @since 2.4.0
      #
      # @see .get
      #
      # @example Proc endpoint
      #   require "hanami/router/app"
      #
      #   class MyApp < Hanami::Router::App
      #     root to: ->(env) { [200, {}, ["Hello from Hanami!"]] }
      #   end
      #
      # @example Block endpoint
      #   require "hanami/router/app"
      #
      #   class MyApp < Hanami::Router::App
      #     root do
      #       "Hello from Hanami!"
      #     end
      #   end
      def self.root(...)
        @router.root(...)
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
      # @since 2.4.0
      #
      # @example Proc endpoint
      #   require "hanami/router/app"
      #
      #   class MyApp < Hanami::Router::App
      #     get "/", to: ->(*) { [200, {}, ["OK"]] }
      #   end
      #
      # @example Block endpoint
      #   require "hanami/router/app"
      #
      #   class MyApp < Hanami::Router::App
      #     get "/" do
      #       "OK"
      #     end
      #   end
      #
      # @example Constraints
      #   require "hanami/router/app"
      #
      #   class MyApp < Hanami::Router::App
      #     get "/users/:id", to: ->(*) { [200, {}, ["OK"]] }, id: /\d+/
      #   end
      def self.get(...)
        @router.get(...)
      end

      # Defines a route that accepts POST requests for the given path.
      #
      # @param path [String] the relative URL to be matched
      # @param to [#call] the Rack endpoint
      # @param as [Symbol] a unique name for the route
      # @param constraints [Hash] a set of constraints for path variables
      # @param blk [Proc] the anonymous proc to be used as endpoint for the route
      #
      # @since 2.4.0
      #
      # @see .get
      def self.post(...)
        @router.post(...)
      end

      # Defines a route that accepts PATCH requests for the given path.
      #
      # @param path [String] the relative URL to be matched
      # @param to [#call] the Rack endpoint
      # @param as [Symbol] a unique name for the route
      # @param constraints [Hash] a set of constraints for path variables
      # @param blk [Proc] the anonymous proc to be used as endpoint for the route
      #
      # @since 2.4.0
      #
      # @see .get
      def self.patch(...)
        @router.patch(...)
      end

      # Defines a route that accepts PUT requests for the given path.
      #
      # @param path [String] the relative URL to be matched
      # @param to [#call] the Rack endpoint
      # @param as [Symbol] a unique name for the route
      # @param constraints [Hash] a set of constraints for path variables
      # @param blk [Proc] the anonymous proc to be used as endpoint for the route
      #
      # @since 2.4.0
      #
      # @see .get
      def self.put(...)
        @router.put(...)
      end

      # Defines a route that accepts DELETE requests for the given path.
      #
      # @param path [String] the relative URL to be matched
      # @param to [#call] the Rack endpoint
      # @param as [Symbol] a unique name for the route
      # @param constraints [Hash] a set of constraints for path variables
      # @param blk [Proc] the anonymous proc to be used as endpoint for the route
      #
      # @since 2.4.0
      #
      # @see .get
      def self.delete(...)
        @router.delete(...)
      end

      # Defines a route that accepts TRACE requests for the given path.
      #
      # @param path [String] the relative URL to be matched
      # @param to [#call] the Rack endpoint
      # @param as [Symbol] a unique name for the route
      # @param constraints [Hash] a set of constraints for path variables
      # @param blk [Proc] the anonymous proc to be used as endpoint for the route
      #
      # @since 2.4.0
      #
      # @see .get
      def self.trace(...)
        @router.trace(...)
      end

      # Defines a route that accepts OPTIONS requests for the given path.
      #
      # @param path [String] the relative URL to be matched
      # @param to [#call] the Rack endpoint
      # @param as [Symbol] a unique name for the route
      # @param constraints [Hash] a set of constraints for path variables
      # @param blk [Proc] the anonymous proc to be used as endpoint for the route
      #
      # @since 2.4.0
      #
      # @see .get
      def self.options(...)
        @router.options(...)
      end

      # Defines a route that accepts LINK requests for the given path.
      #
      # @param path [String] the relative URL to be matched
      # @param to [#call] the Rack endpoint
      # @param as [Symbol] a unique name for the route
      # @param constraints [Hash] a set of constraints for path variables
      # @param blk [Proc] the anonymous proc to be used as endpoint for the route
      #
      # @since 2.4.0
      #
      # @see .get
      def self.link(...)
        @router.link(...)
      end

      # Defines a route that accepts UNLINK requests for the given path.
      #
      # @param path [String] the relative URL to be matched
      # @param to [#call] the Rack endpoint
      # @param as [Symbol] a unique name for the route
      # @param constraints [Hash] a set of constraints for path variables
      # @param blk [Proc] the anonymous proc to be used as endpoint for the route
      #
      # @since 2.4.0
      #
      # @see .get
      def self.unlink(...)
        @router.unlink(...)
      end

      # Defines a route that redirects the incoming request to another path.
      #
      # `code:` is required. For the common cases, prefer {.redirect_permanent}
      # (301) or {.redirect_temporary} (302).
      #
      # @param path [String] the relative URL to be matched
      # @param to [#call] the Rack endpoint
      # @param as [Symbol] a unique name for the route
      # @param code [Integer] a HTTP status code to use for the redirect
      #
      # @since 2.4.0
      #
      # @see .get
      # @see .redirect_permanent
      # @see .redirect_temporary
      def self.redirect(...)
        @router.redirect(...)
      end

      # Defines a route that permanently redirects (301) the incoming request to
      # another path.
      #
      # @param path [String] the relative URL to be matched
      # @param to [#call] the Rack endpoint
      # @param as [Symbol] a unique name for the route
      #
      # @since 2.4.0
      #
      # @see .redirect
      # @see .redirect_temporary
      def self.redirect_permanent(...)
        @router.redirect_permanent(...)
      end

      # Defines a route that temporarily redirects (302) the incoming request to
      # another path.
      #
      # @param path [String] the relative URL to be matched
      # @param to [#call] the Rack endpoint
      # @param as [Symbol] a unique name for the route
      #
      # @since 2.4.0
      #
      # @see .redirect
      # @see .redirect_permanent
      def self.redirect_temporary(...)
        @router.redirect_temporary(...)
      end

      # Defines a routing scope. Routes defined in the context of a scope,
      # inherit the given path as path prefix and as a named routes prefix.
      #
      # @param path [String] the scope path to be used as a path prefix
      # @param blk [Proc] the routes definitions withing the scope
      #
      # @since 2.4.0
      #
      # @see #path
      #
      # @example
      #   require "hanami/router/app"
      #
      #   class MyApp < Hanami::Router::App
      #     scope "v1" do
      #       get "/users", to: ->(*) { ... }, as: :users
      #     end
      #   end
      #
      #   # It generates a route with a path `/v1/users`
      def self.scope(...)
        @router.scope(...)
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
      # @since 2.4.0
      #
      # @example
      #   require "hanami/router/app"
      #
      #   class MyApp < Hanami::Router::App
      #     mount MyRackApp.new, at: "/foo"
      #   end
      def self.mount(...)
        @router.mount(...)
      end

      # Use a Rack middleware
      #
      # @param middleware [Class,#call] a Rack middleware
      # @param args [Array<Object>] an optional array of arguments for Rack middleware
      # @param blk [Block] an optional block to pass to the Rack middleware
      #
      # @since 2.4.0
      #
      # @example
      #   require "hanami/router/app"
      #
      #   class MyApp < Hanami::Router::App
      #     use MyRackMiddleware
      #   end
      def self.use(middleware, *args, &blk)
        @router.use(middleware, *args, &blk)
      end

      # @since 2.4.0
      # @api private
      def path(name, variables = {})
        @url_helpers.path(name, variables)
      end

      # @since 2.4.0
      # @api private
      def url(name, variables = {})
        @url_helpers.url(name, variables)
      end
    end
  end
end
