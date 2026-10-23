# frozen_string_literal: true

RSpec.describe "Router: inspection" do
  let(:router) do
    Hanami::Router.new do
      root to: ->(*) {}

      scope "api" do
        root to: ->(*) {}
      end
    end
  end

  it "inspects the routes" do
    expected = [
      "GET     /                             (proc)                        as :root",
      "GET     /api                          (proc)                        as :api_root"
    ]

    actual = Hanami::Router::Formatter::HumanFriendly.new.call(router.routes)
    expected.each do |line|
      expect(actual).to include(line)
    end
  end
end
