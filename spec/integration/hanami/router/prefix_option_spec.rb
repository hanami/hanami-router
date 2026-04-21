# frozen_string_literal: true

RSpec.describe Hanami::Router do
  describe "with prefix option" do
    subject do
      e = endpoint
      described_class.new(base_url: base_url, prefix: prefix) do
        root             to: e
        get     "/home", to: e, as: :get_home
        post    "/home", to: e, as: :post_home
        put     "/home", to: e, as: :put_home
        patch   "/home", to: e, as: :patch_home
        delete  "/home", to: e, as: :delete_home
        trace   "/home", to: e, as: :trace_home
        options "/home", to: e, as: :options_home

        get  "/admin",      to: e, as: :get_admin
        get  "/admin/new",  to: e, as: :new_admin
        get  "/admin/edit", to: e, as: :edit_admin
        post "/admin",      to: e, as: :create_admin
        put  "/admin",      to: e, as: :put_admin

        scope :dashboard do
          get "/home", to: ->(*) {}, as: :home
        end
      end
    end
    let(:base_url) { "https://hanami.test" }
    let(:prefix) { "/admin" }
    let(:endpoint) { ->(*) { [200, {"Content-Length" => "4"}, ["home"]] } }

    it "generates relative URLs with prefix" do
      expect(subject.path(:root)).to eq("/admin")

      expect(subject.path(:get_home)).to eq("/admin/home")
      expect(subject.path(:post_home)).to eq("/admin/home")
      expect(subject.path(:put_home)).to eq("/admin/home")
      expect(subject.path(:patch_home)).to eq("/admin/home")
      expect(subject.path(:delete_home)).to eq("/admin/home")
      expect(subject.path(:trace_home)).to eq("/admin/home")
      expect(subject.path(:options_home)).to eq("/admin/home")

      expect(subject.path(:get_admin)).to eq("/admin/admin")
      expect(subject.path(:new_admin)).to eq("/admin/admin/new")
      expect(subject.path(:create_admin)).to eq("/admin/admin")
      expect(subject.path(:edit_admin)).to eq("/admin/admin/edit")
      expect(subject.path(:put_admin)).to eq("/admin/admin")

      expect(subject.path(:dashboard_home)).to eq("/admin/dashboard/home")
    end

    it "generates absolute URLs with prefix" do
      expect(subject.url(:root)).to eq(URI("https://hanami.test/admin"))

      expect(subject.url(:get_home)).to eq(URI("https://hanami.test/admin/home"))
      expect(subject.url(:post_home)).to eq(URI("https://hanami.test/admin/home"))
      expect(subject.url(:put_home)).to eq(URI("https://hanami.test/admin/home"))
      expect(subject.url(:patch_home)).to eq(URI("https://hanami.test/admin/home"))
      expect(subject.url(:delete_home)).to eq(URI("https://hanami.test/admin/home"))
      expect(subject.url(:trace_home)).to eq(URI("https://hanami.test/admin/home"))
      expect(subject.url(:options_home)).to eq(URI("https://hanami.test/admin/home"))

      expect(subject.url(:dashboard_home)).to eq(URI("https://hanami.test/admin/dashboard/home"))
    end

    it "recognizes requests to root" do
      env = Rack::MockRequest.env_for("/admin")
      status, *_ = subject.call(env)

      expect(status).to eq(200)
    end

    %w[GET POST PUT PATCH DELETE TRACE OPTIONS].each do |verb|
      it "recognizes requests (#{verb})" do
        env = Rack::MockRequest.env_for("/admin/home", method: verb)
        status, _, body = subject.call(env)

        expect(status).to eq(200)
        expect(body).to eq(["home"])
      end
    end

    it "redirect works with prefix" do
      subject = described_class.new(prefix: prefix) do
        redirect "/redirect", to: "/redirect_destination", code: 301
        get "/redirect_destination", to: ->(*) { [200, {}, ["Redirect destination!"]] }
      end

      env = Rack::MockRequest.env_for("/admin/redirect")
      status, headers, = subject.call(env)

      location_header = Hanami::Router.rack_3? ? headers["location"] : headers["Location"]

      expect(status).to eq(301)
      expect(location_header).to eq("/admin/redirect_destination")
    end
  end
end
