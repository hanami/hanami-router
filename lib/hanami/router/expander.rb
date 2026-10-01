# frozen_string_literal: true

require_relative "mustermann_expander"
require_relative "simple_expander"

module Hanami
  class Router
    # Builds the expander that generates a named route's paths
    #
    # @since 3.1.0
    # @api private
    module Expander
      # Returns a simple expander for routes it can expand without Mustermann, and a Mustermann
      # one for the rest.
      #
      # @param path [String] the route's path
      # @param constraints [Hash] the route's constraints for its variables
      #
      # @return [SimpleExpander, MustermannExpander]
      #
      # @since 3.1.0
      # @api private
      def self.fabricate(path, constraints)
        SimpleExpander.fabricate(path, constraints) || MustermannExpander.new(path, constraints)
      end
    end
  end
end
