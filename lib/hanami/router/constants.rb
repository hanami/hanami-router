# frozen_string_literal: true

module Hanami
  class Router
    # Rack env key containing the request body as parsed by the body parser middleware. Signals that
    # the body has already been parsed, so the router should not attempt to parse it again.
    #
    # @api private
    ROUTER_PARSED_BODY = "router.parsed_body"
  end
end
