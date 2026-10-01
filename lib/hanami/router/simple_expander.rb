# frozen_string_literal: true

require_relative "mustermann_expander"

module Hanami
  class Router
    # Generates a named route's paths without Mustermann, for a path that's only unreserved
    # characters, slashes and variables, and for values that need no escaping
    #
    # Anything else is left to a Mustermann expander, built the first time it's needed. Mustermann
    # doesn't check constraints when expanding, so neither does this.
    #
    # @since 3.1.0
    # @api private
    class SimpleExpander
      # @since 3.1.0
      # @api private
      SIMPLE_PATH = %r{\A(?:[a-zA-Z0-9\-._~/]|:\w+)*\z}
      private_constant :SIMPLE_PATH

      # @since 3.1.0
      # @api private
      VARIABLE = /(:\w+)/
      private_constant :VARIABLE

      # @since 3.1.0
      # @api private
      PLAIN_VALUE = /\A[a-zA-Z0-9_]+\z/
      private_constant :PLAIN_VALUE

      # @return [SimpleExpander, nil] nil when the path isn't simple
      #
      # @since 3.1.0
      # @api private
      def self.fabricate(path, constraints)
        return unless SIMPLE_PATH.match?(path)

        parts = path.split(VARIABLE).reject(&:empty?).map do |part|
          part.start_with?(":") ? part[1..].to_sym : part.freeze
        end
        names = parts.grep(Symbol)
        return unless names.uniq.size == names.size

        new(path, constraints, parts, names)
      end

      # @since 3.1.0
      # @api private
      def initialize(path, constraints, parts, names)
        @path = path
        @constraints = constraints
        @parts = parts.freeze
        @names = names.freeze
      end

      # @raise [Mustermann::ExpandError] when the variables don't fill the path
      #
      # @since 3.1.0
      # @api private
      def expand(variables)
        return mustermann.expand(variables) unless simple?(variables)

        @parts.map { |part| part.is_a?(Symbol) ? variables[part].to_s : part }.join
      end

      private

      # Exactly the path's variables, each with a value that needs no escaping
      #
      # @since 3.1.0
      # @api private
      def simple?(variables)
        variables.size == @names.size && @names.all? { |name| plain?(variables[name]) }
      end

      # @since 3.1.0
      # @api private
      def plain?(value)
        case value
        when Integer then true
        when String then PLAIN_VALUE.match?(value)
        else false
        end
      end

      # @since 3.1.0
      # @api private
      def mustermann
        @mustermann ||= MustermannExpander.new(@path, @constraints)
      end
    end
  end
end
