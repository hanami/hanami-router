# frozen_string_literal: true

require_relative "expander/mustermann_expander"
require_relative "expander/simple_expander"

module Hanami
  class Router
    # Builds the expander that generates a named route's paths
    #
    # Constraints aren't checked when expanding, so they play no part here.
    #
    # @since 3.1.0
    # @api private
    module Expander
      # Returns a simple expander for routes it can expand without Mustermann, and a Mustermann
      # one for the rest.
      #
      # @param path [String] the route's path
      #
      # @return [SimpleExpander, MustermannExpander]
      #
      # @since 3.1.0
      # @api private
      def self.fabricate(path)
        SimpleExpander.fabricate(path) || MustermannExpander.new(path)
      end
    end
  end
end
