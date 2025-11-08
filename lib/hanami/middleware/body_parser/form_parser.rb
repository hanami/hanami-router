# frozen_string_literal: true

require_relative "parser"
require "rack/multipart"

module Hanami
  module Middleware
    class BodyParser
      # @since 2.0.1
      # @api private
      class FormParser < Parser
        # @api private
        MEDIA_TYPES = ["multipart/form-data"].freeze

        # @since 2.0.1
        # @api private
        def self.media_types = MEDIA_TYPES

        # Parse a multipart body payload (form file uploading)
        #
        # @return [Hash] the parsed multipart body
        #
        # @raise [Hanami::Middleware::BodyParser::BodyParsingError] when the body can't be parsed.
        #
        # @since 2.0.1
        # @api private
        def parse(*, env)
          # Rewind to ensure successful parsing (required for Rack 3's `.parse_multipart`).
          env[::Rack::RACK_INPUT].rewind if env[::Rack::RACK_INPUT].respond_to?(:rewind)
          ::Rack::Multipart.parse_multipart(env)
        rescue StandardError => exception
          raise BodyParsingError.new(exception.message)
        end
      end
    end
  end
end
