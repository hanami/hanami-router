# frozen_string_literal: true

module Hanami
  class Router
    # @api private
    ROUTER_PARSED_BODY = "router.parsed_body"

    # @api private
    CONTENT_TYPE = "CONTENT_TYPE"

    # @api private
    FORM_URLENCODED_MEDIA_TYPE = "application/x-www-form-urlencoded"

    # @api private
    FORM_URLENCODED_MEDIA_TYPE_PREFIX = "#{FORM_URLENCODED_MEDIA_TYPE};".freeze

    # @api private
    EMPTY_HASH = {}.freeze
  end
end
