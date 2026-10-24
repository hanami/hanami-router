# frozen_string_literal: true

require "hanami/middleware/app"
require "rack/mock"

RSpec.describe Hanami::Middleware::App do
  subject { described_class.new(app, mapping) }

  let(:app) { Hanami::Router.new { root { "OK" } } }
  let(:mapping) { {"/" => [], "/admin" => [[authentication, ["arg"], {kwarg: "kwarg"}, nil]]} }
  let(:authentication) do
    Class.new do
      def self.inspect
        "<Middleware::Auth>"
      end

      def initialize(app, arg, kwarg:)
        @app = app
        @arg = arg
        @kwarg = kwarg
      end

      def call(env)
        env["AUTH_USER_ID"] = user_id = "23 #{@arg} #{@kwarg}"
        status, headers, body = @app.call(env)
        headers["X-Auth-User-ID"] = user_id

        [status, headers, body]
      end
    end
  end

  describe "#initialize" do
    it "returns a #{described_class} instance" do
      expect(subject).to be_kind_of(described_class)
    end
  end

  describe "#call" do
    it "bypasses middleware when not used by given path" do
      env = Rack::MockRequest.env_for("/")
      _, headers, _ = subject.call(env)

      expect(headers).to_not have_key("X-Auth-User-ID")
    end

    it "invokes middleware when used by given path" do
      env = Rack::MockRequest.env_for("/admin")
      _, headers, _ = subject.call(env)

      expect(headers["X-Auth-User-ID"]).to eq "23 arg kwarg"
    end
  end
end
