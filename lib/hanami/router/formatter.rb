# frozen_string_literal: true

module Hanami
  class Router
    # Formatters render a router's {Router#routes}.
    #
    # A formatter is any object that responds to `#call(routes, **options)` and returns a
    # String. It can use the {Route} methods, such as {Route#inspect_to}, to render each route.
    #
    # The built-in formatters load when first used.
    #
    # @example
    #   Hanami::Router::Formatter::HumanFriendly.new.call(router.routes)
    #
    # @api public
    # @since 2.0.0
    module Formatter
      autoload :HumanFriendly, "hanami/router/formatter/human_friendly"
      autoload :CSV, "hanami/router/formatter/csv"
    end
  end
end
