# frozen_string_literal: true

require "hanami/router/leaf"

module Hanami
  class Router
    # Trie node
    #
    # @api private
    # @since 2.0.0
    class Node
      # @api private
      # @since 2.0.0
      def initialize
        @variable = nil
        @fixed = nil
        @leaves = nil
      end

      # @api private
      # @since 2.0.0
      def put(segment, param_keys)
        if variable?(segment)
          param_keys << segment.delete_prefix(Router::ROUTE_VARIABLE_INDICATOR).freeze
          @variable ||= self.class.new
        else
          @fixed ||= {}
          @fixed[segment] ||= self.class.new
        end
      end

      # @api private
      # @since 2.0.0
      def get(segment, param_values)
        fixed = @fixed&.fetch(segment, nil)
        return fixed if fixed

        param_values << segment

        @variable
      end

      # @api private
      # @since 2.0.0
      def leaf!(param_keys, to, constraints)
        @leaves ||= []
        @leaves << Leaf.new(param_keys, to, constraints)
      end

      # @api private
      # @since 2.2.0
      def match(param_values)
        @leaves&.find { |leaf| leaf.match(param_values) }
      end

      private

      # @api private
      # @since 2.0.0
      def variable?(segment)
        segment.include?(Router::ROUTE_VARIABLE_INDICATOR)
      end
    end
  end
end
