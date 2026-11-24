# frozen_string_literal: true

require_relative "node"

module Hanami
  module Middleware
    # Trie to register scopes with custom Rack middleware
    #
    # @api private
    # @since 2.0.0
    class Trie
      # @api private
      # @since 2.0.0
      def initialize(app)
        @app = app
        @root = Node.new
      end

      # @api private
      # @since 2.0.0
      def freeze
        @root.freeze
        super
      end

      # @api private
      # @since 2.0.0
      def add(path, app)
        node = @root
        for_each_segment(path) do |segment|
          node = node.put(segment)
        end

        node.app!(app)
      end

      # @api private
      # @since 2.0.0
      def find(path)
        node = @root
        app = @root.app

        # Track the deepest scope with an app on the way down. When the descent stops early (a
        # segment with no matching child under a node that has children), the request is still
        # within that scope, so its middleware must apply.
        for_each_segment(path) do |segment|
          node = node.get(segment)
          break unless node

          app = node.app if node.app?
        end

        app || @app
      end

      # @api private
      # @since 2.0.0
      def empty?
        @root.leaf?
      end

      private

      # @api private
      # @since 2.0.0
      def for_each_segment(path, &blk)
        _, *segments = path.split("/")
        segments.each(&blk)
      end
    end
  end
end
