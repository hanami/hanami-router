# frozen_string_literal: true

require "rack/utils"
require_relative "segment"

module Hanami
  class Router
    # Generates a named route's paths with Mustermann
    #
    # @since 3.1.0
    # @api private
    class MustermannExpander
      # @since 3.1.0
      # @api private
      def initialize(path, constraints)
        @segment = Segment.fabricate(path, **constraints)
      end

      # Variables the path doesn't have are added to the query string, as are arrays.
      #
      # @raise [Mustermann::ExpandError] when the variables don't fill the path
      #
      # @since 3.1.0
      # @api private
      def expand(variables)
        scalar_vars = variables.reject { |_, value| value.is_a?(Array) }
        array_vars = array_query_vars(variables)

        expanded_path = @segment.expand(:append, scalar_vars)
        return expanded_path if array_vars.empty?

        join_char = expanded_path.include?("?") ? "&" : "?"
        "#{expanded_path}#{join_char}#{Rack::Utils.build_query(array_vars)}"
      end

      private

      # @since 3.1.0
      # @api private
      def array_query_vars(variables)
        variables
          .select { |_, value| value.is_a?(Array) }
          .to_h { |key, value| ["#{key}[]", value] }
      end
    end
  end
end
