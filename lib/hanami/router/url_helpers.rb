# frozen_string_literal: true

require "hanami/router/errors"
require "mustermann/error"
require_relative "prefix"

module Hanami
  class Router
    # @api private
    class UrlHelpers
      # @since 2.0.0
      # @api private
      def initialize(base_url)
        @base_url = URI(base_url)
        @named = {}
        prefix = @base_url.path
        prefix = DEFAULT_PREFIX if prefix.empty?
        @prefix = Prefix.new(prefix)
      end

      # @api private
      def add(name, segment)
        @named[name] = segment
      end

      # @api private
      def path(name, variables = {})
        scalar_vars = variables.reject { |_, value| value.is_a?(Array) }
        array_vars = array_query_vars(variables)

        expanded_path = @named
          .fetch(name.to_sym) { raise MissingRouteError.new(name) }
          .expand(:append, scalar_vars)

        return expanded_path if array_vars.empty?

        join_char = expanded_path.include?("?") ? "&" : "?"
        "#{expanded_path}#{join_char}#{Rack::Utils.build_query(array_vars)}"
      rescue Mustermann::ExpandError => exception
        raise InvalidRouteExpansionError.new(name, exception.message)
      end

      # @api private
      def url(name, variables = {})
        @base_url + @prefix.join(path(name, variables)).to_s
      end

      private

      def array_query_vars(variables = {})
        variables
          .select { |_, value| value.is_a?(Array) }
          .to_h { |key, value| ["#{key}[]", value] }
      end
    end
  end
end
