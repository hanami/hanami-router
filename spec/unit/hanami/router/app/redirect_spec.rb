# frozen_string_literal: true

require "hanami/router/app"
require "rack/mock"

RSpec.describe Hanami::Router::App do
  describe "redirect" do
    subject do
      Class.new(described_class) do
        get "/" do
          "home"
        end

        redirect_permanent("/dashboard", to: "/")
        redirect_temporary("/temporary", to: "/")
        redirect("/custom", to: "/", code: 303)
        redirect_permanent("/as", to: "/", as: :named)
      end.new
    end

    it "permanently redirects to destination" do
      env = Rack::MockRequest.env_for("/dashboard")
      status, headers, body = subject.call(env)

      expect(status).to eq(301)
      expect(headers).to eq(rack_headers("Location" => "/"))
      expect(body).to eq(["Moved Permanently"])
    end

    it "temporarily redirects to destination" do
      env = Rack::MockRequest.env_for("/temporary")
      status, headers, body = subject.call(env)

      expect(status).to eq(302)
      expect(headers).to eq(rack_headers("Location" => "/"))
      expect(body).to eq(["Found"])
    end

    it "accepts a custom HTTP code" do
      env = Rack::MockRequest.env_for("/custom")
      status, headers, body = subject.call(env)

      expect(status).to eq(303)
      expect(headers).to eq(rack_headers("Location" => "/"))
      expect(body).to eq(["See Other"])
    end

    it "accepts as:" do
      expect(subject.path(:named)).to eq("/as")
    end
  end
end
