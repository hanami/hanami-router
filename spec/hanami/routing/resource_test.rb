require 'test_helper'

describe Hanami::Router do
  before do
    @router = Hanami::Router.new
    @app    = Rack::MockRequest.new(@router)
  end

  after do
    @router.reset!
  end

  describe '#resource' do
    before do
      @router.resource 'avatar'
    end

    it 'recognizes get new' do
      @router.path(:new_avatar).must_equal                           '/avatar/new'
      @app.request('GET', '/avatar/new', lint: true).body.must_equal 'Avatar::New'
    end

    it 'recognizes post create' do
      @router.path(:avatar).must_equal                            '/avatar'
      @app.request('POST', '/avatar', lint: true).body.must_equal 'Avatar::Create'
    end

    it 'recognizes get show' do
      @router.path(:avatar).must_equal                           '/avatar'
      @app.request('GET', '/avatar', lint: true).body.must_equal 'Avatar::Show'
    end

    it 'recognizes get edit' do
      @router.path(:edit_avatar).must_equal                           '/avatar/edit'
      @app.request('GET', '/avatar/edit', lint: true).body.must_equal 'Avatar::Edit'
    end

    it 'recognizes patch update' do
      @router.path(:avatar).must_equal                             '/avatar'
      @app.request('PATCH', '/avatar', lint: true).body.must_equal 'Avatar::Update'
    end

    it 'recognizes delete destroy' do
      @router.path(:avatar).must_equal                              '/avatar'
      @app.request('DELETE', '/avatar', lint: true).body.must_equal 'Avatar::Destroy'
    end

    describe ':only option' do
      before do
        @router.resource 'profile', only: [:edit, :update]
      end

      it 'recognizes only specified paths' do
        @router.path(:edit_profile).must_equal                           '/profile/edit'
        @app.request('GET', '/profile/edit', lint: true).body.must_equal 'Profile::Edit'

        @router.path(:profile).must_equal                             '/profile'
        @app.request('PATCH', '/profile', lint: true).body.must_equal 'Profile::Update'
      end

      it 'does not recognize other paths' do
        @app.request('GET',    '/profile/new', lint: true).status.must_equal 405
        @app.request('POST',   '/profile', lint: true).status.must_equal     405
        @app.request('GET',    '/profile', lint: true).status.must_equal     405
        @app.request('DELETE', '/profile', lint: true).status.must_equal     405

        exception = -> { @router.path(:new_profile) }.must_raise Hanami::Routing::InvalidRouteException
        exception.message.must_equal 'No route (path) could be generated for :new_profile - please check given arguments'
      end
    end

    describe ':except option' do
      before do
        @router.resource 'profile', except: [:new, :show, :create, :destroy]
      end

      it 'recognizes only the non-rejected paths' do
        @router.path(:edit_profile).must_equal                           '/profile/edit'
        @app.request('GET', '/profile/edit', lint: true).body.must_equal 'Profile::Edit'

        @router.path(:profile).must_equal                             '/profile'
        @app.request('PATCH', '/profile', lint: true).body.must_equal 'Profile::Update'
      end

      it 'does not recognize other paths' do
        @app.request('GET',    '/profile/new', lint: true).status.must_equal 405
        @app.request('POST',   '/profile', lint: true).status.must_equal     405
        @app.request('GET',    '/profile', lint: true).status.must_equal     405
        @app.request('DELETE', '/profile', lint: true).status.must_equal     405

        exception = -> { @router.path(:new_profile) }.must_raise Hanami::Routing::InvalidRouteException
        exception.message.must_equal 'No route (path) could be generated for :new_profile - please check given arguments'
      end
    end

    describe 'member' do
      before do
        @router.resource 'profile', only: [:new] do
          member do
            patch 'activate'
            patch '/deactivate'
          end
        end
      end

      it 'recognizes the path' do
        @router.path(:activate_profile).must_equal                             '/profile/activate'
        @app.request('PATCH', '/profile/activate', lint: true).body.must_equal 'Profile::Activate'
      end

      it 'recognizes the path with a leading slash' do
        @router.path(:deactivate_profile).must_equal                             '/profile/deactivate'
        @app.request('PATCH', '/profile/deactivate', lint: true).body.must_equal 'Profile::Deactivate'
      end
    end

    describe 'collection' do
      before do
        @router.resource 'profile', only: [:new] do
          collection do
            get 'keys'
            get '/activities'
          end
        end
      end

      it 'recognizes the path' do
        @router.path(:keys_profile).must_equal                           '/profile/keys'
        @app.request('GET', '/profile/keys', lint: true).body.must_equal 'Profile::Keys'
      end

      it 'recognizes the path with a leading slash' do
        @router.path(:activities_profile).must_equal                           '/profile/activities'
        @app.request('GET', '/profile/activities', lint: true).body.must_equal 'Profile::Activities'
      end
    end

    describe 'controller' do
      before do
        @router.resource 'profile', controller: 'keys', only: [:new]
      end

      it 'recognizes path with different controller' do
        @router.path(:new_profile).must_equal                           '/profile/new'
        @app.request('GET', '/profile/new', lint: true).body.must_equal 'Keys::New'
      end
    end

    describe ':as option' do
      before do
        @router.resource 'keyboard', as: 'piano' do
          collection do
            get 'search'
          end

          member do
            get 'screenshot'
          end
        end
      end

      it 'recognizes the new name' do
        @router.path(:piano).must_equal '/keyboard'
        @router.path(:new_piano).must_equal '/keyboard/new'
        @router.path(:edit_piano).must_equal '/keyboard/edit'
        @router.path(:search_piano).must_equal '/keyboard/search'
        @router.path(:screenshot_piano).must_equal '/keyboard/screenshot'
      end

      it 'does not recognize the resource name' do
        e = Hanami::Routing::InvalidRouteException
        -> { @router.path(:keyboard) }.must_raise e
        -> { @router.path(:new_keyboard) }.must_raise e
        -> { @router.path(:edit_keyboard) }.must_raise e
        -> { @router.path(:search_keyboard) }.must_raise e
        -> { @router.path(:screenshot_keyboard) }.must_raise e
      end
    end
  end
end
