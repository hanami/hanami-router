# frozen_string_literal: true

RSpec.describe Hanami::Router::MountedPath do
  let(:prefix) { Mustermann.new("/api", type: :rails, version: "5.0") }
  let(:app) { double(:app) }

  subject { described_class.new(prefix, app) }

  describe "#endpoint_and_params" do
    let(:env) { {} }

    it "returns an empty array if the path doesn't match the prefix" do
      env.merge!(Rack::PATH_INFO => "/checkout")

      expect(subject.endpoint_and_params(env)).to eq([])
    end

    it "returns the app and named captures when the path matches" do
      env.merge!(Rack::PATH_INFO => "/api/orders")

      expect(subject.endpoint_and_params(env)).to eq([app, {}])
    end

    context "with a root prefix" do
      let(:prefix) { Mustermann.new("/", type: :rails, version: "5.0") }

      before :each do
        env.merge!(Rack::PATH_INFO => "/orders")
      end

      it "keeps the leading slash in the PATH_INFO" do
        subject.endpoint_and_params(env)

        expect(env[Rack::PATH_INFO]).to eq("/orders")
      end

      it "sets SCRIPT_NAME to be an empty string" do
        subject.endpoint_and_params(env)

        expect(env[Rack::SCRIPT_NAME]).to eq("")
      end
    end

    context "with a non-root prefix" do
      before :each do
        env.merge!(Rack::PATH_INFO => "/api/orders")
      end

      it "adds the prefix to the SCRIPT_NAME" do
        subject.endpoint_and_params(env)

        expect(env[Rack::SCRIPT_NAME]).to eq("/api")
      end

      it "removes the prefix from the PATH_INFO" do
        subject.endpoint_and_params(env)

        expect(env[Rack::PATH_INFO]).to eq("/orders")
      end

      it "uses a slash for the PATH_INFO if it would otherwise be empty" do
        env.merge!(Rack::PATH_INFO => "/api")

        subject.endpoint_and_params(env)

        expect(env[Rack::PATH_INFO]).to eq("/")
      end
    end

    context "with a prefix containing dynamic segments" do
      let(:prefix) { Mustermann.new("/stations/:station_id", type: :rails, version: "5.0") }

      before :each do
        env.merge!(Rack::PATH_INFO => "/stations/42/trains")
      end

      it "adds the matched path to the SCRIPT_NAME" do
        subject.endpoint_and_params(env)

        expect(env[Rack::SCRIPT_NAME]).to eq("/stations/42")
      end

      it "removes the matched portion from the PATH_INFO" do
        subject.endpoint_and_params(env)

        expect(env[Rack::PATH_INFO]).to eq("/trains")
      end

      it "returns the app and named captures" do
        result = subject.endpoint_and_params(env)

        expect(result).to eq([app, {"station_id" => "42"}])
      end
    end
  end
end
