# frozen_string_literal: true

require "hanami/router/node"

module Hanami
  class Router
    # Trie data structure to store routes
    #
    # @api private
    # @since 2.0.0
    class Trie
      # @api private
      # @since 2.0.0
      attr_reader :root

      # @api private
      # @since 2.0.0
      def initialize
        @root = Node.new
      end

      # @api private
      # @since 2.0.0
      def add(route, to, constraints)
        node = @root
        param_keys = []

        segments_from(route).each do |segment|
          node = node.put(segment, param_keys)
        end

        node.leaf!(param_keys, to, constraints)
      end

      # @api private
      # @since 2.0.0
      def find(path)
        node = @root
        param_values = []

        path.slice(1..).split(SEGMENT_SEPARATOR) do |segment|
          node = node.get(segment, param_values)

          break if node.nil?
        end

        node&.match(param_values)&.then { |found| [found.to, found.params] }
      end

      private

      # @api private
      # @since 2.0.0
      SEGMENT_SEPARATOR = "/"
      private_constant :SEGMENT_SEPARATOR

      # @api private
      # @since 2.2.0
      def segments_from(path)
        _, *segments = path.split(SEGMENT_SEPARATOR)

        segments
      end
    end
  end
end
