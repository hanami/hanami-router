# frozen_string_literal: true

require "mustermann/rails"

module Hanami
  class Router
    class Leaf
      # Trie Leaf
      #
      # @api private
      # @since 2.2.0
      attr_reader :to, :params, :matcher

      # @api private
      # @since 2.2.0
      def initialize(route, to, constraints)
        @to = to
        @params = nil
        @matcher = Mustermann.new(route, type: :rails, version: "5.0", capture: constraints)
      end

      # @api private
      # @since 2.2.0
      def match(path)
        match = matcher.match(path)

        @params = match.named_captures if match

        match
      end
    end
  end
end
