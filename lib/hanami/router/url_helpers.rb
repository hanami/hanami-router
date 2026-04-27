# frozen_string_literal: true

require "hanami/router/errors"
require "mustermann/error"
require_relative "prefix"

module Hanami
  class Router
    # @since 2.0.0
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

      # @since 2.0.0
      # @api private
      def add(name, segment)
        @named[name] = segment
      end

      # @since 2.0.0
      # @api private
      def path(name, variables = {})
        safe_variables = variables.reject do |key, value|
          value.is_a?(Array)
        end
        array_variables = extract_and_patch_array_variables(variables)

        expanded_path = @named.fetch(name.to_sym) do
          raise MissingRouteError.new(name)
        end.expand(:append, safe_variables)

        append_array_variables(expanded_path, array_variables)
      rescue Mustermann::ExpandError => exception
        raise InvalidRouteExpansionError.new(name, exception.message)
      end

      # @since 2.0.0
      # @api private
      def url(name, variables = {})
        @base_url + @prefix.join(path(name, variables)).to_s
      end

      # @since 2.3.3
      # @api private
      def extract_and_patch_array_variables(variables = {})
        variables.select do |key, value|
          value.is_a?(Array)
        end.to_h do |key, value|
          ["#{key}[]", value]
        end
      end

      # @since 2.3.3
      # @api private
      def append_array_variables(expanded_path, array_variables)
        if array_variables.empty?
          expanded_path
        else
          array_query = Rack::Utils.build_query(array_variables)
          join_char = expanded_path =~ /\?/ ? "&" : "?"
          "#{expanded_path}#{join_char}#{array_query}"
        end
      end
    end
  end
end
