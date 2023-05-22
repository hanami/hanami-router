RSpec.describe Hanami::Middleware::BodyParser do
  it "inherits from Hanami::Routing::Error" do
    expect(Hanami::Middleware::BodyParser::BodyParsingError.superclass).to eq(Hanami::Middleware::Error)
    expect(Hanami::Middleware::BodyParser::UnknownParserError.superclass).to eq(Hanami::Middleware::Error)
    expect(Hanami::Middleware::BodyParser::InvalidParserError.superclass).to eq(Hanami::Middleware::Error)
  end
end
