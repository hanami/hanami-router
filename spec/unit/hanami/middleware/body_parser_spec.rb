# frozen_string_literal: true

require "hanami/middleware/body_parser"
require "hanami/middleware/body_parser/json_parser"

RSpec.describe Hanami::Middleware::BodyParser do
  describe ".build" do
    let(:parser_class) do
      Class.new(Hanami::Middleware::BodyParser::Parser) do
        def self.media_types = ["text"]
        def parse(body) = body
      end
    end

    it "requires and initializes a parser by name" do
      expect(described_class.build(:json)).to be_a(Hanami::Middleware::BodyParser::JsonParser)
      expect(described_class.build("json")).to be_a(Hanami::Middleware::BodyParser::JsonParser)
    end

    it "raises an exception if a named parser cannot be found" do
      expect { described_class.build(:unknown) }.to raise_exception(Hanami::Middleware::BodyParser::UnknownParserError)
    end

    it "initializes a parser from a class" do
      expect(described_class.build(parser_class)).to be_a(parser_class)
    end

    it "passes through a parser instance" do
      parser = parser_class.new
      expect(described_class.build(parser)).to eql parser
    end

    it "raises an exception if the parser does not conform to requirements" do
      parser = Object.new
      expect { described_class.build(parser) }.to raise_exception(Hanami::Middleware::BodyParser::InvalidParserError)
    end
  end
end
