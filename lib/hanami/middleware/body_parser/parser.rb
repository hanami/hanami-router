# frozen_string_literal: true

module Hanami
  module Middleware
    class BodyParser
      # Body parser abstract class
      #
      # @since 2.0.0
      class Parser
        class << self
          def media_types = []
          alias_method :mime_types, :media_types
        end

        # Return supported media types
        #
        # @return [Array<String>] supported media types
        #
        # @abstract
        # @since 2.0.0
        #
        # @example
        #   require "hanami/middleware/body_parser"
        #
        #   class XMLParser < Hanami::Middleware::BodyParser::Parser
        #     def self.media_types
        #       ["application/xml", "text/xml"]
        #     end
        #   end
        attr_reader :media_types
        alias_method :mime_types, :media_types

        # @api private
        def initialize(media_types: [])
          @media_types = self.class.media_types + media_types
        end

        # Parse raw HTTP request body
        #
        # @param body [String] HTTP request body
        # @param env [Hash] Rack env
        #
        # @return [Hash] the result of the parsing
        #
        # @raise [Hanami::Middleware::BodyParser::BodyParsingError] the error
        #   that must be raised if the parsing cannot be accomplished
        #
        # @abstract
        # @since 2.0.0
        #
        # @example
        #   require "hanami/middleware/body_parser"
        #
        #   class XMLParser < Hanami::Middleware::BodyParser::Parser
        #     def parse(body)
        #       # XML parsing
        #       # ...
        #     rescue => exception
        #       raise Hanami::Middleware::BodyParser::BodyParsingError.new(exception.message)
        #     end
        #   end
        def parse(body, env = {}) # rubocop:disable Lint/UnusedMethodArgument
          raise NoMethodError
        end
      end
    end
  end
end
