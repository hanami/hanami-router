# frozen_string_literal: true

module Hanami
  class Router
    class MountedPath
      def initialize(prefix, app)
        @prefix = prefix
        @app = app
      end

      def endpoint_and_params(env)
        return [] unless (match = @prefix.peek_match(env[::Rack::PATH_INFO]))

        if @prefix.to_s == "/"
          env[::Rack::SCRIPT_NAME] = EMPTY_STRING
        else
          # To set SCRIPT_NAME, use the actual matched portion of the path, not the prefix string
          # itself. This is important for prefixes with dynamic segments like "/stations/:id". In
          # this case, we want e.g. "/stations/42" as SCRIPT_NAME, not "/stations/:id".
          matched_path = match.to_s
          env[::Rack::SCRIPT_NAME] = env[::Rack::SCRIPT_NAME].to_s + matched_path
          env[::Rack::PATH_INFO] = env[::Rack::PATH_INFO].sub(matched_path, EMPTY_STRING)
          env[::Rack::PATH_INFO] = DEFAULT_PREFIX if env[::Rack::PATH_INFO] == EMPTY_STRING
        end

        [@app, match.named_captures]
      end
    end
  end
end
