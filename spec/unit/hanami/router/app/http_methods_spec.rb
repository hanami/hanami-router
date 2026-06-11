# frozen_string_literal: true

require "hanami/router/app"
require "rack/mock"

RSpec.describe Hanami::Router::App do
  describe "HTTP methods" do
    RSpec::Support::HTTP.mountable_verbs.each do |http_method|
      context http_method.upcase do
        subject do
          Class.new(described_class) do
            send(http_method, "/") { "hello world (#{http_method})" }
          end.new
        end

        it "accepts a request" do
          env = Rack::MockRequest.env_for("/", method: http_method.upcase)
          status, _, body = subject.call(env)

          expect(status).to eq(200)
          expect(body).to eq(["hello world (#{http_method})"])
        end
      end
    end
  end
end
