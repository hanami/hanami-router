# frozen_string_literal: true

require "hanami/middleware/trie"

RSpec.describe Hanami::Middleware::Trie do
  subject { described_class.new(app) }
  let(:app) { -> (*) { [200, {"Content-Length" => "2"}, ["OK"]] } }

  describe "#initialize" do
    it "returns an instance of #{described_class}" do
      expect(subject).to be_kind_of(described_class)
    end
  end

  describe "#add" do
    it "adds node" do
      subject.add("/foo", double("foo"))
    end
  end

  describe "#find" do
    before do
      subject.add("/admin", admin)
      subject.add("/api", api)
      subject.add("/api/v1", api_v1)
    end
    let(:admin) { double("admin") }
    let(:api) { double("api") }
    let(:api_v1) { double("api_v1") }

    it "finds nodes by given path" do
      expect(subject.find("/")).to eq(app)
      expect(subject.find("/admin")).to eq(admin)
      expect(subject.find("/admin/")).to eq(admin) # trailing slash
      expect(subject.find("/api")).to eq(api)
      expect(subject.find("/api/v1")).to eq(api_v1)
    end

    it "matches path prefix" do
      expect(subject.find("/admin/users")).to eq(admin)
      expect(subject.find("/api/v1/songs")).to eq(api_v1)
      expect(subject.find("/api/v1/songs/")).to eq(api_v1) # trailing slash
    end

    it "falls back to app, if no node is associated with given path" do
      expect(subject.find("/foo")).to eq(app)
    end

    it "matches the nearest enclosing scope when a nested scope exists" do
      expect(subject.find("/api/songs")).to eq(api)
      expect(subject.find("/api/songs/1")).to eq(api)
      expect(subject.find("/api/v2/songs")).to eq(api)
    end
  end

  describe "#empty?" do
    context "without nodes" do
      it "returns true" do
        expect(subject).to be_empty
      end
    end

    context "with nodes" do
      it "returns false" do
        subject.add("/bar", double("bar"))
        expect(subject).to_not be_empty
      end
    end
  end
end
