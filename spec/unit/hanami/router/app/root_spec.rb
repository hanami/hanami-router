# frozen_string_literal: true

require "hanami/router/app"
require "rack/mock"

RSpec.describe Hanami::Router::App do
  describe "#root" do
    subject do
      Class.new(described_class) do
        root do
          "hello world"
        end
      end.new
    end

    let(:app) { Rack::MockRequest.new(subject) }

    it "accepts a request" do
      response = app.get("/", lint: true)

      expect(response.body).to eq("hello world")
    end
  end
end
