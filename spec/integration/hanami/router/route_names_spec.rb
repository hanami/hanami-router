# frozen_string_literal: true

RSpec.describe Hanami::Router, "route names" do
  let(:handler) { -> (body) { [200, {}, [body]] } }

  it "makes a route available by its name" do
    router = described_class.new do
      get "/cats", to: -> {}, as: :cats
    end

    expect(router.path("cats")).to eq "/cats"
  end

  it "prefixes route names by their scopes" do
    router = described_class.new do
      scope "backend" do
        get "/cats", to: -> {}, as: :cats

        scope "admin", as: :secret do
          get "/cats", to: -> {}, as: :cats
        end
      end
    end

    expect(router.path("backend_cats")).to eq "/backend/cats"
    expect(router.path("backend_secret_cats")).to eq "/backend/admin/cats"
  end

  it "allows route names to provide their own prefix" do
    router = described_class.new do
      scope "backend" do
        scope "admin", as: :secret do
          get "/cats", to: -> {}, as: :cats
          get "/cats/new", to: -> {}, as: [:new, :cat]

          get "/dogs", to: -> {}, as: [:dogs]
          get "/dogs/new", to: -> {}, as: [:new, :very, :good, :boy]
        end
      end
    end

    expect(router.path("backend_secret_cats")).to eq "/backend/admin/cats"
    expect(router.path("new_backend_secret_cat")).to eq "/backend/admin/cats/new"
    expect(router.path("backend_secret_dogs")).to eq "/backend/admin/dogs"
    expect(router.path("new_backend_secret_very_good_boy")).to eq "/backend/admin/dogs/new"
  end
end
