# frozen_string_literal: true

module Hanami
  class Router
    # URL Path prefix
    #
    # @since 2.0.0
    # @api private
    class Prefix
      # @since 2.0.0
      # @api private
      def initialize(prefix)
        @prefix = prefix
      end

      # @since 2.0.0
      # @api private
      def join(path)
        self.class.new(
          _join(path)
        )
      end

      # @since 2.0.0
      # @api private
      #
      # Returns only the prefix, with no trailing separator, when the path is empty.
      def relative_join(path, separator = DEFAULT_SEPARATOR)
        path = path.to_s
        joined = path.empty? ? @prefix : _join(path)

        joined.gsub(DEFAULT_SEPARATOR_REGEXP, separator)[1..].to_s
      end

      # @since 2.0.0
      # @api private
      def to_s
        @prefix
      end

      # @since 2.0.0
      # @api private
      def to_sym
        @prefix.to_sym
      end

      private

      # @since 2.0.0
      # @api private
      DEFAULT_SEPARATOR = "/"

      # @since 2.0.0
      # @api private
      DEFAULT_SEPARATOR_REGEXP = /\//

      # @since 2.0.0
      # @api private
      DOUBLE_DEFAULT_SEPARATOR_REGEXP = /\/{2,}/

      # @since 2.0.0
      # @api private
      def _join(path)
        return @prefix if path == DEFAULT_SEPARATOR

        (@prefix + DEFAULT_SEPARATOR + path)
          .gsub(DOUBLE_DEFAULT_SEPARATOR_REGEXP, DEFAULT_SEPARATOR)
      end
    end
  end
end
