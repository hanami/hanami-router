# frozen_string_literal: true

RSpec.describe Hanami::Router do
  describe "recorded routes" do
    it "uses original to value to generate the route" do
      resolver = ->(_path, _to) { Class.new }

      router = Hanami::Router.new(resolver: resolver) do
        get "/", to: "home#index"
      end

      expect(router.routes.first.inspect_to).to eq("home#index")
    end

    it "uses resolved block value to generate the route" do
      router = Hanami::Router.new do
        get "/" do
          "Block"
        end
      end

      expect(router.routes.first.inspect_to).to eq("(block)")
    end
  end
end
