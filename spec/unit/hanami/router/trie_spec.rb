# frozen_string_literal: true

require "hanami/router/trie"

RSpec.describe Hanami::Router::Trie do
  describe "#initialize" do
    it "returns an instance of #{described_class}" do
      expect(subject).to be_kind_of(described_class)
    end
  end

  describe "#find" do
    before do
      subject.add("/:foo", foo, foo_constraints)
      subject.add("/:foo/bar", bar, foo_constraints)
      subject.add("/:baz", baz, empty_constraints)
    end
    let(:foo) { double("foo") }
    let(:bar) { double("bar") }
    let(:baz) { double("baz") }
    let(:foo_constraints) { {foo: /\d+/} }
    let(:empty_constraints) { {} }

    it "matches path with variable segment and matching constraints" do
      to, params = subject.find("/123")

      expect(to).to eq(foo)
      expect(params).to eq({"foo" => "123"})
    end

    it "matches path with variable segment followed by fixed segment" do
      to, params = subject.find("/123/bar")

      expect(to).to eq(bar)
      expect(params).to eq({"foo" => "123"})
    end

    it "matches correct path with variable segment based on constraints" do
      to, params = subject.find("/qux")

      expect(to).to eq(baz)
      expect(params).to eq({"baz" => "qux"})
    end
  end
end
