# frozen_string_literal: true

require "mustermann/error"

module Hanami
  class Router
    # Route path template, for generating paths without Mustermann
    #
    # @since 3.1.0
    # @api private
    class PathTemplate
      # @since 3.1.0
      # @api private
      PLAIN_VALUE = /\A[a-zA-Z0-9_]+\z/
      private_constant :PLAIN_VALUE

      # @since 3.1.0
      # @api private
      PLACEHOLDER = /hanamirouterplaceholder\d+z/
      private_constant :PLACEHOLDER

      # @since 3.1.0
      # @api private
      def self.fabricate(segment)
        names = segment.names.map(&:to_sym)
        return unless unconstrained?(segment.options[:capture], names)

        parts = parts_for(segment, names)
        new(parts, names) if parts.grep(Symbol).sort == names.sort
      rescue Mustermann::ExpandError
        nil
      end

      # @since 3.1.0
      # @api private
      def self.parts_for(segment, names)
        placeholders = names.each_with_index.to_h { |name, index| [name, "hanamirouterplaceholder#{index}z"] }
        variables = placeholders.invert

        segment.expand(:raise, placeholders)
          .split(/(#{PLACEHOLDER})/o)
          .reject(&:empty?)
          .map { |part| variables.fetch(part) { part.freeze } }
      end
      private_class_method :parts_for

      # @since 3.1.0
      # @api private
      def self.unconstrained?(capture, names)
        case capture
        when nil then true
        when Hash then capture.keys.none? { |key| names.include?(key.to_sym) }
        else false
        end
      end
      private_class_method :unconstrained?

      # @since 3.1.0
      # @api private
      def initialize(parts, names)
        @parts = parts.freeze
        @names = names.freeze
        freeze
      end

      # @since 3.1.0
      # @api private
      def expand(variables)
        return unless variables.size == @names.size && @names.all? { |name| plain?(variables[name]) }

        @parts.map { |part| part.is_a?(Symbol) ? variables[part].to_s : part }.join
      end

      private

      # @since 3.1.0
      # @api private
      def plain?(value)
        case value
        when Integer then !value.negative?
        when String then PLAIN_VALUE.match?(value)
        else false
        end
      end
    end
  end
end
