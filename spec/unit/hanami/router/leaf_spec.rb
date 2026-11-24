# frozen_string_literal: true

require "hanami/router/leaf"

RSpec.describe Hanami::Router::Leaf do
  let(:subject)     { described_class.new(route, to, constraints) }
  let(:route)       { "/test/route" }
  let(:to)          { "test proc" }
  let(:constraints) { {} }

  describe "#initialize" do
    it "returns a #{described_class} instance" do
      expect(subject).to be_kind_of(described_class)
    end
  end

  describe "#to" do
    it "returns the endpoint passed as 'to' when initialized" do
      expect(subject.to).to eq(to)
    end
  end

  describe "#match" do
    context "when path matches route" do
      let(:matching_path) { route }

      it "returns the (empty) captured params" do
        expect(subject.match(matching_path)).to eq({})
      end
    end

    context "when path doesn't match route" do
      let(:non_matching_path) { "/bad/path" }

      it "returns nil" do
        expect(subject.match(non_matching_path)).to be_nil
      end
    end

    context "with variable path" do
      let(:route) { "test/:route" }

      it "returns captured params" do
        expect(subject.match("test/path")).to eq("route" => "path")
      end

      # Leaves are shared by concurrent requests, so matching must not write per-request state to
      # the leaf. A frozen leaf proves this: any write would raise FrozenError.
      it "does not store per-request state on the leaf" do
        subject.freeze

        expect(subject.match("test/one")).to eq("route" => "one")
        expect(subject.match("test/two")).to eq("route" => "two")
      end
    end
  end
end
