# frozen_string_literal: true

require "hanami/router/node"
require "hanami/router/leaf"

RSpec.describe Hanami::Router::Node do
  describe "#initialize" do
    it "returns a #{described_class} instance" do
      expect(subject).to be_kind_of(described_class)
    end
  end

  describe "#get" do
    context "when segment is found" do
      context "and segment is fixed" do
        it "returns a node" do
          segment = "foo"
          subject.put(segment)

          expect(subject.get(segment)).to be_kind_of(described_class)
        end
      end

      context "and segment is variable" do
        it "returns a node" do
          dynamic_segment = ":foo"
          subject.put(dynamic_segment)

          expect(subject.get("bar")).to be_kind_of(described_class)
        end
      end
    end

    context "when segment is not found" do
      it "returns nil" do
        segment = "foo"
        subject.put(segment)

        expect(subject.get("bar")).to be_nil
      end
    end
  end

  describe "#match" do
    context "when segment is fixed" do
      context "and match not found" do
        it "returns nil" do
          segment = "foo"
          route = "/foo"
          to = double("to")
          constraints = {}
          path = "/bar"
          subject.put(segment).leaf!(route, to, constraints)

          expect(subject.get(segment).match(path)).to be_nil
        end
      end

      context "and match is found" do
        it "returns the endpoint and captured params" do
          segment = "foo"
          route = "/foo"
          to = double("to")
          constraints = {}
          subject.put(segment).leaf!(route, to, constraints)

          expect(subject.get(segment).match(route)).to eq([to, {}])
        end
      end
    end

    context "when segment is variable" do
      context "and match not found" do
        it "returns nil" do
          segment = ":foo"
          route = "/:foo"
          to = double("to")
          constraints = {foo: :digit}
          path = "/bar"
          subject.put(segment).leaf!(route, to, constraints)

          expect(subject.get(segment).match(path)).to be_nil
        end
      end

      context "and match found" do
        it "returns the endpoint and captured params" do
          segment = ":foo"
          route = "/:foo"
          to = double("to")
          constraints = {foo: :digit}
          path = "/123"
          subject.put(segment).leaf!(route, to, constraints)

          expect(subject.get(segment).match(path)).to eq([to, {"foo" => "123"}])
        end
      end
    end
  end
end
