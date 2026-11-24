# frozen_string_literal: true

require "mustermann/rails"

module Hanami
  class Router
    class Leaf
      # Trie Leaf
      #
      # @api private
      # @since 2.2.0
      attr_reader :to, :matcher

      # @api private
      # @since 2.2.0
      def initialize(route, to, constraints)
        @to = to
        @matcher = Mustermann.new(route, type: :rails, version: "5.0", capture: constraints)
      end

      # Returns the captured params for the given path, or nil if the path doesn't match.
      #
      # Leaves are shared across concurrent requests, so the captures are returned rather than
      # stored on the leaf.
      #
      # @api private
      # @since 2.2.0
      def match(path)
        matcher.match(path)&.named_captures
      end
    end
  end
end
