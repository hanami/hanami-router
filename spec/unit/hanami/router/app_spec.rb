# frozen_string_literal: true

require "hanami/router/app"
require "rack/mock"

RSpec.describe Hanami::Router::App do
  subject do
    Class.new(described_class) do
      get "/" do
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
