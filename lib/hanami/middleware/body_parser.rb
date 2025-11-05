# frozen_string_literal: true

require "hanami/router/params"
require "hanami/middleware/error"
require_relative "../router/constants"

module Hanami
  module Middleware
    # @since 1.3.0
    # @api private
    class BodyParser
      require_relative "body_parser/class_interface"
      require_relative "body_parser/parser"

      # @since 1.3.0
      # @api private
      CONTENT_TYPE = "CONTENT_TYPE"

      # @since 1.3.0
      # @api private
      MEDIA_TYPE_MATCHER = /\s*[;,]\s*/

      # @since 1.3.0
      # @api private
      RACK_INPUT = "rack.input"

      # @since 1.3.0
      # @api private
      ROUTER_PARAMS = "router.params"

      # @api private
      FALLBACK_KEY = "_"

      extend ClassInterface

      def initialize(app, parsers)
        @app = app
        @parsers = parsers
      end

      def call(env)
        return @app.call(env) if env.key?(Router::ROUTER_PARSED_BODY)

        input = env[RACK_INPUT]
        return @app.call(env) unless input

        parser = @parsers[media_type(env)]
        return @app.call(env) unless parser

        # The input in Rack 3 is not rewindable. For compatbility with Rack 2, make the input
        # rewindable, rewind it for reading, then rewind once more before returning to the app.
        input = env[RACK_INPUT] = Rack::RewindableInput.new(input) unless input.respond_to?(:rewind)
        input.rewind
        body = input.read
        input.rewind

        return @app.call(env) if body.nil? || body.empty?

        env[Router::ROUTER_PARSED_BODY] = parser.parse(body, env)
        env[ROUTER_PARAMS] = _symbolize(env[Router::ROUTER_PARSED_BODY])

        @app.call(env)
      end

      private

      def _symbolize(body)
        if body.is_a?(::Hash)
          Router::Params.deep_symbolize(body)
        else
          {FALLBACK_KEY => body}
        end
      end

      def media_type(env)
        ct = content_type(env)
        return unless ct

        ct.split(MEDIA_TYPE_MATCHER, 2).first.downcase
      end

      def content_type(env)
        content_type = env[CONTENT_TYPE]
        content_type.nil? || content_type.empty? ? nil : content_type
      end
    end
  end
end
