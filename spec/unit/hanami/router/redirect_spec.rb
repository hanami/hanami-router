# frozen_string_literal: true

RSpec.describe Hanami::Router do
  describe "#redirect_permanent" do
    it "redirects with 301" do
      endpoint = ->(_env) { [200, {}, ["Redirect destination!"]] }
      router = Hanami::Router.new do
        get "/redirect_destination", to: endpoint, as: :destination
        redirect_permanent "/redirect", to: "/redirect_destination"
      end

      env = Rack::MockRequest.env_for("/redirect")
      status, headers, = router.call(env)

      expect(status).to eq(301)
      expect(headers[Hanami::Router::HTTP_HEADER_LOCATION]).to eq("/redirect_destination")
    end

    it "redirects to an absolute url" do
      router = Hanami::Router.new do
        redirect_permanent "/redirect", to: "https://hanamirb.org/"
      end

      env = Rack::MockRequest.env_for("/redirect")
      status, headers, = router.call(env)

      expect(status).to eq(301)
      expect(headers[Hanami::Router::HTTP_HEADER_LOCATION]).to eq("https://hanamirb.org/")
    end
  end

  describe "#redirect_temporary" do
    it "redirects with 302" do
      endpoint = ->(_env) { [200, {}, ["Redirect destination!"]] }
      router = Hanami::Router.new do
        get "/redirect_destination", to: endpoint, as: :destination
        redirect_temporary "/redirect", to: "/redirect_destination"
      end

      env = Rack::MockRequest.env_for("/redirect")
      status, headers, = router.call(env)

      expect(status).to eq(302)
      expect(headers[Hanami::Router::HTTP_HEADER_LOCATION]).to eq("/redirect_destination")
    end

    it "redirects to an absolute url" do
      router = Hanami::Router.new do
        redirect_temporary "/redirect", to: "https://hanamirb.org/"
      end

      env = Rack::MockRequest.env_for("/redirect")
      status, headers, = router.call(env)

      expect(status).to eq(302)
      expect(headers[Hanami::Router::HTTP_HEADER_LOCATION]).to eq("https://hanamirb.org/")
    end
  end

  describe "#redirect" do
    it "requires code:" do
      expect {
        Hanami::Router.new do
          redirect "/redirect", to: "/redirect_destination"
        end
      }.to raise_error(ArgumentError, /missing keyword: :?code/)
    end

    it "redirects with the given code" do
      endpoint = ->(_env) { [200, {}, ["Redirect destination!"]] }
      router = Hanami::Router.new do
        get "/redirect_destination", to: endpoint, as: :destination
        redirect "/redirect", to: "/redirect_destination", code: 307
      end

      env = Rack::MockRequest.env_for("/redirect")
      status, headers, = router.call(env)

      expect(status).to eq(307)
      expect(headers[Hanami::Router::HTTP_HEADER_LOCATION]).to eq("/redirect_destination")
    end

    it "raises UnknownHTTPStatusCodeError for an unknown code" do
      expect {
        Hanami::Router.new do
          redirect "/redirect", to: "/redirect_destination", code: 999
        end
      }.to raise_error(Hanami::Router::UnknownHTTPStatusCodeError, /999/)
    end

    it "recognizes relative path that starts like an absolute url but is not" do
      endpoint = ->(_env) { [200, {}, ["Redirect destination!"]] }
      router = Hanami::Router.new do
        get "/http:redirect_destination", to: endpoint, as: :destination
        redirect "/redirect", to: "/http:redirect_destination", code: 303
      end

      env = Rack::MockRequest.env_for("/redirect")
      status, headers, = router.call(env)

      expect(status).to eq(303)
      expect(headers[Hanami::Router::HTTP_HEADER_LOCATION]).to eq("/http:redirect_destination")
    end

    it "recognizes URI endpoint" do
      router = Hanami::Router.new do
        redirect "/redirect", to: URI("custom://hanamirb.org/1234"), code: 308
      end

      env = Rack::MockRequest.env_for("/redirect")
      status, headers, = router.call(env)

      expect(status).to eq(308)
      expect(headers[Hanami::Router::HTTP_HEADER_LOCATION]).to eq("custom://hanamirb.org/1234")
    end
  end
end
