# frozen_string_literal: true

require "json"
require "pathname"
require "rack/builder"
require "rack/multipart"
require "hanami/middleware/body_parser"

RSpec.describe "Params" do
  subject { router }

  let(:router) do
    e = endpoint

    Hanami::Router.new do
      get "/search",  to: e
      post "/submit", to: e
      patch "/user/:id/update", to: e
    end
  end

  let(:endpoint) { ->(*) { [200, {}, ["OK"]] } }

  context "plain request" do
    it "has empty params on GET request" do
      env = Rack::MockRequest.env_for("/search")
      subject.call(env)

      expect(env["router.params"]).to eq({})
    end

    it "has empty params on POST request" do
      env = Rack::MockRequest.env_for("/submit", method: "POST")
      subject.call(env)

      expect(env["router.params"]).to eq({})
    end
  end

  context "query string" do
    it "has params from GET query string" do
      env = Rack::MockRequest.env_for("/search?q=hanami")
      subject.call(env)

      expect(env["router.params"]).to eq(q: "hanami")
    end
  end

  context "form payload" do
    it "has params from POST form submission" do
      input = {"preferences" => {"language" => "Ruby", "framework" => "Hanami", "completion" => "100%"}}
      env = Rack::MockRequest.env_for("/submit", method: "POST", params: input)
      subject.call(env)

      expected = Hanami::Router::Params.deep_symbolize(input)
      expect(env["router.params"]).to eq(expected)
    end

    it "ignores missing 'rack.input'" do
      env = Rack::MockRequest.env_for("/submit", method: "POST")
      env.delete("rack.input")
      subject.call(env)

      expect(env["router.params"]).to eq({})
    end

    it "rewinds 'rack.input'" do
      input = {"foo" => 23}
      env = Rack::MockRequest.env_for("/submit", method: "POST", params: input)
      subject.call(env)

      expected = Rack::Utils.build_nested_query(input)
      expect(env["rack.input"].read).to eq(expected)
    end
  end

  context "file upload" do
    subject do
      r = router

      Rack::Builder.new do
        use Hanami::Middleware::BodyParser, :form
        run r
      end
    end

    it "handles file upload" do
      filename = "foo.xml"
      env, contents = multipart_fixture(filename)

      subject.call(env)

      uploaded_file = env["router.params"].fetch(:file)

      expect(uploaded_file.fetch(:filename)).to eq(filename)
      expect(uploaded_file.fetch(:tempfile).read).to eq(contents)
    end
  end

  context "JSON payload" do
    subject do
      r = router

      Rack::Builder.new do
        use Hanami::Middleware::BodyParser, :json
        run r
      end
    end

    # See: https://github.com/hanami/router/issues/237
    it "doesn't parse when body parser is mounted" do
      input = JSON.generate("foo" => "100% bar")
      env = Rack::MockRequest.env_for("/submit", method: "POST", params: input)
      env["CONTENT_TYPE"] = "application/json"
      subject.call(env)

      expect(env["router.params"]).to eq(foo: "100% bar")
    end
  end

  context "JSON payload without body parser" do
    # See: https://github.com/hanami/router/issues/237
    it "doesn't merge a JSON body into params" do
      input = JSON.generate("foo" => "bar")
      env = Rack::MockRequest.env_for("/submit?from=ui", method: "POST", params: input)
      env["CONTENT_TYPE"] = "application/json"
      subject.call(env)

      expect(env["router.params"]).to eq(from: "ui")
    end
  end

  context "priority" do
    it "gives first level priority to path variables" do
      expected = "23"
      env = Rack::MockRequest.env_for("/user/#{expected}/update?id=1", method: "PATCH", params: {id: 2})
      subject.call(env)

      expect(env["router.params"]).to eq(id: expected)
    end

    it "gives second level priority to query string variables" do
      expected = "23"
      env = Rack::MockRequest.env_for("/submit?id=#{expected}", method: "POST", params: {id: 2})
      subject.call(env)

      expect(env["router.params"]).to eq(id: expected)
    end
  end

  private

  def multipart_fixture(filename, boundary = Rack::Multipart::MULTIPART_BOUNDARY)
    path = fixture_path(filename)
    file = Rack::Multipart::UploadedFile.new(path)
    data = Rack::Multipart.build_multipart("file" => file)

    env = Rack::MockRequest.env_for(
      "/submit",
      "CONTENT_TYPE" => "multipart/form-data; boundary=#{boundary}",
      "CONTENT_LENGTH" => data.length.to_s,
      method: "POST",
      :input => StringIO.new(data)
    )

    [env, File.binread(path)]
  end

  def fixture_path(name)
    Pathname.new(Dir.pwd).join("spec", "support", "fixtures", name).realpath
  end
end
