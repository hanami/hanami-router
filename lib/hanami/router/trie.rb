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
        @segments_map = {}
      end

      # @api private
      # @since 2.0.0
      def add(route, to, constraints)
        segments = segments_from(route)
        node = @root

        segments.each do |segment|
          node = node.put(segment)
        end

        node.leaf!(route, to, constraints)
      end

      # @api private
      # @since 2.0.0
      def find(path)
        segments = segments_from(path)
        node = @root

        return unless segments.all? { |segment| node = node.get(segment) }

        node.match(path)&.then { |found| [found.to, found.params] }
      end

      private

      # @api private
      # @since 2.0.0
      SEGMENT_SEPARATOR = "/"
      private_constant :SEGMENT_SEPARATOR

      # @api private
      # @since 2.2.0
      def segments_from(path)
        if @segments_map[path]
          @segments_map[path]
        else
          _, *segments = path.split(SEGMENT_SEPARATOR)
          @segments_map[path] = segments
        end
      end
    end
  end
end
