# frozen_string_literal: true

module RSpec
  module Support
    module HTTP
      if defined?(::Rack::QUERY)
        MOUNTABLE_VERBS = %w[get post delete put patch trace options link unlink query].freeze
      else
        MOUNTABLE_VERBS = %w[get post delete put patch trace options link unlink].freeze
      end

      VERBS = MOUNTABLE_VERBS + %w[head].freeze

      def self.mountable_verbs
        MOUNTABLE_VERBS
      end

      def self.verbs
        VERBS
      end

      def self.testable?(mounted, requested)
        (mounted == requested) ||
          (mounted == "get" && requested == "head")
      end
    end
  end
end
