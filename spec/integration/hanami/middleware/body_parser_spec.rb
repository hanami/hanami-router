# frozen_string_literal: true

require "hanami/middleware/body_parser"
require "rack/mock"

RSpec.describe Hanami::Middleware::BodyParser do
  let(:app) { ->(_env) { [200, {}, "app"] } }

  describe ".new" do
    it "accepts a parser name" do
      body_parser = Hanami::Middleware::BodyParser.new(app, :json)

      expect(body_parser.instance_variable_get("@parsers")["application/json"])
        .to be_instance_of(Hanami::Middleware::BodyParser::JsonParser)
    end

    it "accepts a parser name with additional media type" do
      body_parser = Hanami::Middleware::BodyParser.new(app, [json: "application/json+scim"])

      expect(body_parser.instance_variable_get("@parsers")["application/json+scim"])
        .to be_instance_of(Hanami::Middleware::BodyParser::JsonParser)
    end

    it "accepts a parser name with additional media types" do
      body_parser = Hanami::Middleware::BodyParser.new(
        app, [json: ["application/json+scim", "application/json+foo"]]
      )

      expect(body_parser.instance_variable_get("@parsers")["application/json+scim"])
        .to be_instance_of(Hanami::Middleware::BodyParser::JsonParser)
    end

    it "accepts multiple parser names with additional media type" do
      class Hanami::Middleware::BodyParser::XmlParser < Hanami::Middleware::BodyParser::Parser
        def self.media_types = ["application/xml"]
      end

      body_parser = Hanami::Middleware::BodyParser.new(
        app, [{json: "application/json+scim", xml: ["application/xml"]}]
      )

      parsers = body_parser.instance_variable_get("@parsers")

      expect(parsers["application/json+scim"])
        .to be_instance_of(Hanami::Middleware::BodyParser::JsonParser)

      expect(parsers["application/xml"])
        .to be_instance_of(Hanami::Middleware::BodyParser::XmlParser)

      Hanami::Middleware::BodyParser.__send__(:remove_const, :XmlParser)
    end

    it "accepts multiple parser class ids" do
      class Hanami::Middleware::BodyParser::XmlParser < Hanami::Middleware::BodyParser::Parser
        def self.media_types = ["application/xml"]
      end

      body_parser = Hanami::Middleware::BodyParser.new(app, [:json, :xml])

      parsers = body_parser.instance_variable_get("@parsers")

      expect(parsers["application/json"])
        .to be_instance_of(Hanami::Middleware::BodyParser::JsonParser)

      expect(parsers["application/xml"])
        .to be_instance_of(Hanami::Middleware::BodyParser::XmlParser)

      Hanami::Middleware::BodyParser.__send__(:remove_const, :XmlParser)
    end

    it "raises error when parser spec is invalid" do
      Hanami::Middleware::BodyParser.new(app, :a_parser)
    rescue Hanami::Middleware::BodyParser::UnknownParserError => exception
      expect(exception.message).to eq("Unknown body parser: `:a_parser'")
    end

    it "accepts a custom parser class" do
      custom_parser_class = Class.new(Hanami::Middleware::BodyParser::Parser) do
        def self.media_types = ["application/custom"]
        def parse(_body) = "custom"
      end

      body_parser = Hanami::Middleware::BodyParser.new(app, custom_parser_class)
      expect(body_parser.instance_variable_get("@parsers")["application/custom"])
        .to be_instance_of(custom_parser_class)

      body_parser = Hanami::Middleware::BodyParser.new(app, [custom_parser_class => "application/x-custom"])
      expect(body_parser.instance_variable_get("@parsers")["application/custom"])
        .to be_instance_of(custom_parser_class)
      expect(body_parser.instance_variable_get("@parsers")["application/x-custom"])
        .to be_instance_of(custom_parser_class)
    end
  end
end
