# frozen_string_literal: true

RSpec.describe "Pass on response" do
  before do
    @routes = Hanami::Router.new { get "/", to: ->(_env) { Rack::Response.new } }
    @app    = Rack::MockRequest.new(@routes)
  end

  it "is successful" do
    response = @app.get("/", lint: true)
    expect(response.status).to eq(200)
  end
end
