# frozen_string_literal: true

require "hanami/router/inspector"

RSpec.describe "Router: inspection" do
  let!(:router) do
    Hanami::Router.new(inspector: inspector) do
      root to: ->(*) {}

      scope "api" do
        root to: ->(*) {}
      end
    end
  end

  let(:inspector) { Hanami::Router::Inspector.new }

  it "inspects the routes" do
    expected = [
      "GET     /                                  (proc)                             as :root            ",
      "GET     /api                               (proc)                             as :api_root        "
    ]

    actual = inspector.call
    expected.each do |line|
      expect(actual).to include(line)
    end
  end
end
