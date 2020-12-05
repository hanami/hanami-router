# frozen_string_literal: true

require "hanami/router/error"
require "mustermann/error"

module Hanami
  class Router
    # URL Helpers
    class UrlHelpers
      # @since 2.0.0
      # @api private
      def initialize(base_url)
        @base_url = base_url
        @named = {}
      end

      # @since 2.0.0
      # @api private
      def add(name, segment)
        @named[name] = segment
      end

      # @since 2.0.0
      # @api public
      def path(name, variables = {})
        @named.fetch(name.to_sym) do
          raise InvalidRouteException.new(name)
        end.expand(:append, variables)
      rescue Mustermann::ExpandError => exception
        raise InvalidRouteExpansionException.new(name, exception.message)
      end

      # @since 2.0.0
      # @api public
      def url(name, variables = {})
        @base_url + path(name, variables)
      end
    end
  end
end
