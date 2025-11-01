# frozen_string_literal: true

require "hanami/middleware/body_parser"
require "rack/mock"

RSpec.describe Hanami::Middleware::BodyParser do
  describe "JSON parser" do
    subject(:env) do
      Rack::MockRequest.env_for("/", method: "POST", "CONTENT_TYPE" => content_type, input: body).tap do |env|
        middleware.call(env)
      end
    end

    let(:app) { ->(_env) { [200, {}, "app"] } }
    let(:middleware) { Hanami::Middleware::BodyParser.new(app, [:json]) }
    let(:body)         { "" }
    let(:content_type) { "" }

    describe "JSON request" do
      let(:body)         { %({"attribute":"ok"}) }
      let(:content_type) { "application/json" }

      it "parses params from body" do
        expect(env["router.params"]).to eq(attribute: "ok")
      end

      it "stores parsed body" do
        expect(env["router.parsed_body"]).to eq("attribute" => "ok")
      end

      describe "with non hash body" do
        let(:body) { %(["foo"]) }

        it "parses params from body" do
          expect(env["router.params"]).to eq("_" => ["foo"])
        end

        it "stores parsed body" do
          expect(env["router.parsed_body"]).to eq(["foo"])
        end
      end

      describe "with malformed json" do
        let(:body) { %({"hanami":"ok" "attribute":"ok"}) }
        it "raises an exception" do
          expect { env }.to raise_error(Hanami::Middleware::BodyParser::BodyParsingError)
        end
      end
    end

    describe "JSON API request" do
      let(:body)         { %({"data": {"attribute":"ok"}}) }
      let(:content_type) { "application/vnd.api+json" }

      it "parses params from body" do
        expect(env["router.params"]).to eq(data: {attribute: "ok"})
      end

      it "stores parsed body" do
        expect(env["router.parsed_body"]).to eq("data" => {"attribute" => "ok"})
      end

      # See https://github.com/hanami/router/issues/237
      context "when payload contains '%'" do
        let(:body) { %({"foo": "%"}) }

        it "parses params from body" do
          expect(env["router.params"]).to eq(foo: "%")
          expect(env["router.parsed_body"]).to eq("foo" => "%")
        end
      end

      describe "with malformed json" do
        let(:body) {  %({"hanami":"ok" "attribute":"ok"}) }

        it "raises an exception" do
          expect { env }.to raise_error(Hanami::Middleware::BodyParser::BodyParsingError)
        end
      end
    end

    describe "request with body previously read" do
      subject(:env) do
        Rack::MockRequest.env_for("/", method: "POST", "CONTENT_TYPE" => content_type, input: body).tap do |env|
          Rack::RewindableInput.new(env["rack.input"]).read
          middleware.call(env)
        end
      end

      context "request matches a parser" do
        let(:body) { %({"attribute":"ok"}) }
        let(:content_type) { "application/json" }

        it "rewinds the body and parses it" do
          expect(env["router.params"]).to eq(attribute: "ok")
        end

        it "rewinds the body after parsing" do
          expect(env["rack.input"].read).to eq body
        end
      end

      context "request does not match a parser" do
        let(:body) { "hello world" }
        let(:content_type) { "application/custom" }

        it "does not parse the body" do
          expect(env.keys).not_to include("router.parsed_body")
          expect(env.keys).not_to include("router.params")
        end

        it "rewinds the body" do
          expect(env["rack.input"].read).to eq body
        end
      end
    end

    describe "request with unknown content type" do
      let(:body)         { %(<element>ok</element>) }
      let(:content_type) { "application/xml" }

      it "does not parse body params" do
        expect(env.keys).not_to include("router.parsed_body")
        expect(env.keys).not_to include("router.params")
      end
    end

    describe "request without content type" do
      let(:body) { "hanami=ok" }

      it "does not parse body params" do
        expect(env.keys).not_to include("router.parsed_body")
        expect(env.keys).not_to include("router.params")
      end
    end

    describe "requerst without body" do
      let(:body) { nil }

      it "does not parse body params" do
        expect(env.keys).not_to include("router.parsed_body")
        expect(env.keys).not_to include("router.params")
      end
    end
  end
end
