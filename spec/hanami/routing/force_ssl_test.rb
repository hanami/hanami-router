require 'test_helper'

describe Hanami::Router do
  # Bug https://github.com/hanami/router/issues/73
  it 'respects the Rack spec' do
    router = Hanami::Router.new(force_ssl: true)
    router.public_send(:get, '/http_destination', to: ->(env) { [200, {}, ['http destination!']] })
    app = Rack::MockRequest.new(router)

    app.get('/http_destination', lint: true)
  end

  %w{get}.each do |verb|
    it "force_ssl to true and scheme is http, return 307 and new location, verb: #{verb}" do
      router = Hanami::Router.new(force_ssl: true)
      router.public_send(verb, '/http_destination', to: ->(env) { [200, {}, ['http destination!']] })
      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination', lint: true)

      status.must_equal 301
      headers['Location'].must_equal 'https://localhost:443/http_destination'
      body.body.must_equal ''
    end

    it "force_ssl to true and scheme is https, return 200, verb: #{verb}" do
      router = Hanami::Router.new(force_ssl: true, scheme: 'https', host: 'hanami.test')
      router.public_send(verb, '/http_destination', to: ->(env) { [200, {}, ['http destination!']] })
      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, 'https://hanami.test/http_destination', lint: true)

      status.must_equal 200
      headers['Location'].must_be_nil
      body.body.must_equal 'http destination!'
    end
  end

  %w{post put patch delete options}.each do |verb|
    it "force_ssl to true and scheme is http, return 307 and new location, verb: #{verb}" do
      router = Hanami::Router.new(force_ssl: true)
      router.public_send(verb, '/http_destination', to: ->(env) { [200, {}, ['http destination!']] })
      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination', lint: true)

      status.must_equal 307
      headers['Location'].must_equal 'https://localhost:443/http_destination'
      body.body.must_equal ''
    end

    it "force_ssl to true and added query string, verb: #{verb}" do
      router = Hanami::Router.new(force_ssl: true)
      router.public_send(verb, '/http_destination', to: ->(env) { [200, {}, ['http destination!']] })

      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination?foo=bar', lint: true)

      status.must_equal 307
      headers['Location'].must_equal 'https://localhost:443/http_destination?foo=bar'
      body.body.must_equal ''
    end

    it "force_ssl to true and added port, verb: #{verb}" do
      router = Hanami::Router.new(force_ssl: true, port: 4000)
      router.public_send(verb, '/http_destination', to: ->(env) { [200, {}, ['http destination!']] })

      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination?foo=bar', lint: true)

      status.must_equal 307
      headers['Location'].must_equal 'https://localhost:4000/http_destination?foo=bar'
      body.body.must_equal ''
    end

    it "force_ssl to true, added host and port, verb: #{verb}" do
      router = Hanami::Router.new(force_ssl: true, host: 'hanamirb.org', port: 4000)
      router.public_send(verb, '/http_destination', to: ->(env) { [200, {}, ['http destination!']] })

      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination?foo=bar', lint: true)

      status.must_equal 307
      headers['Location'].must_equal 'https://hanamirb.org:4000/http_destination?foo=bar'
      body.body.must_equal ''
    end

    it "force_ssl to false and scheme is http, return 200 and doesn't return new location, verb: #{verb}" do
      router = Hanami::Router.new(force_ssl: false)
      router.public_send(verb, '/http_destination', to: ->(env) { [200, {}, ['http destination!']] })

      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination', lint: true)

      status.must_equal 200
      headers['Location'].must_be_nil
      body.body.must_equal 'http destination!'
    end

    it "force_ssl to false and scheme is https, return 200 and doesn't return new location, verb: #{verb}" do
      router = Hanami::Router.new(force_ssl: false, scheme: 'https')
      router.public_send(verb, '/http_destination', to: ->(env) { [200, {}, ['http destination!']] })

      app = Rack::MockRequest.new(router)

      status, headers, body = app.public_send(verb, '/http_destination', lint: true)

      status.must_equal 200
      headers['Location'].must_be_nil
      body.body.must_equal 'http destination!'
    end
  end
end
