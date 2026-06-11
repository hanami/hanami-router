# frozen_string_literal: true

require "hanami/router/app"
require "rack/mock"

RSpec.describe Hanami::Router::App do
  describe "mount" do
    subject do
      app = ->(env) { [200, {}, ["HTTP method: #{env['REQUEST_METHOD']}"]] }

      Class.new(described_class) do
        mount app, at: "/v1"
      end.new
    end

    RSpec::Support::HTTP.mountable_verbs.each do |http_method|
      it "accepts #{http_method.upcase} requests" do
        env = Rack::MockRequest.env_for("/v1/users", method: http_method.upcase)
        status, _, body = subject.call(env)

        expect(status).to eq(200)
        expect(body).to eq(["HTTP method: #{http_method.upcase}"])
      end
    end
  end
end
