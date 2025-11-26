# frozen_string_literal: true

require "rack/test"

RSpec.describe "SCRIPT_NAME" do
  include Rack::Test::Methods

  before do
    @container = Hanami::Router.new do
      @some_test_router = Hanami::Router.new do
        get "/foo", to: ->(env) { [200, {}, [::Rack::Request.new(env).url]] }, as: :foo
      end
      mount @some_test_router, at: "/admin"
    end
  end

  def app
    @container
  end

  def response
    last_response
  end

  def request
    last_request
  end

  pending "generates proper path" do
    router = @container.instance_variable_get(:@some_test_router)
    expect(router.path(:foo)).to eq("/admin/foo")
  end

  pending "generates proper url" do
    router = @container.instance_variable_get(:@some_test_router)
    expect(router.url(:foo).to_s).to eq("http://localhost/admin/foo")
  end

  it "sets SCRIPT_NAME to the mount point" do
    path = "/admin/foo"
    get path

    expect(response.status).to eq(200)
    expect(request.env["SCRIPT_NAME"]).to eq("/admin")
    expect(request.env["SCRIPT_NAME"]).to be_kind_of(String)

    expect(request.env["PATH_INFO"]).to eq("/foo")
    expect(request.env["PATH_INFO"]).to be_kind_of(String)
    expect(response.body).to eq("http://example.org#{path}")
  end
end
