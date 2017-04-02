require 'test_helper'

describe Hanami::Router do
  describe '.new' do
    before do
      class MockRoute
      end

      endpoint = ->(env) { [200, {}, ['']] }
      @router = Hanami::Router.new do
        root                to: endpoint
        get '/route',       to: endpoint
        get '/named_route', to: endpoint, as: :named_route
        resource  'avatar'
        resources 'flowers'
        namespace 'admin' do
          get '/dashboard', to: endpoint
        end
      end

      @app = Rack::MockRequest.new(@router)
    end

    it 'returns instance of Hanami::Router with empty block' do
      router = Hanami::Router.new { }
      router.must_be_instance_of Hanami::Router
    end

    it 'evaluates routes passed from Hanami::Router.define' do
      routes = Hanami::Router.define { post '/domains', to: ->(env) {[201, {}, ['Domain Created']]} }
      router = Hanami::Router.new(&routes)

      app      = Rack::MockRequest.new(router)
      response = app.post('/domains', lint: true)

      response.status.must_equal 201
      response.body.must_equal   'Domain Created'
    end

    it 'returns instance of Hanami::Router' do
      @router.must_be_instance_of Hanami::Router
    end

    it 'sets options' do
      router = Hanami::Router.new(scheme: 'https') do
        root to: ->(env) { }
      end

      router.url(:root).must_match('https')
    end

    it 'sets custom separator' do
      router = Hanami::Router.new(action_separator: '^')
      route  = router.root(to: 'test^show')

      route.dest.must_equal(Test::Show)
    end

    it 'checks if there are defined routes' do
      router = Hanami::Router.new
      router.wont_be :defined?

      router = Hanami::Router.new { get '/', to: ->(env) { } }
      router.must_be :defined?
    end

    it 'recognizes root' do
      @app.get('/', lint: true).status.must_equal 200
    end

    it 'recognizes path' do
      @app.get('/route', lint: true).status.must_equal 200
    end

    it 'recognizes named path' do
      @app.get('/named_route', lint: true).status.must_equal 200
    end

    it 'recognizes resource' do
      @app.get('/avatar', lint: true).status.must_equal 200
    end

    it 'recognizes resources' do
      @app.get('/avatar', lint: true).status.must_equal 200
    end

    it 'recognizes namespaced path' do
      @app.get('/admin/dashboard', lint: true).status.must_equal 200
    end
  end
end
