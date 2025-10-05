# frozen_string_literal: true

require "hanami/router/node"
require "hanami/router/leaf"

RSpec.describe Hanami::Router::Node do
  describe "#initialize" do
    it "returns a #{described_class} instance" do
      result = subject

      expect(result).to be_kind_of(described_class)
    end
  end

  describe "#put" do
    context "when segment is fixed" do
      it "does not update param_keys" do
        segment = "foo"
        param_keys = []

        subject.put(segment, param_keys)

        expect(param_keys).to be_empty
      end
    end

    context "when segment is variable" do
      it "updates param_keys" do
        variable_segment = ":foo"
        key_for_variable_segment = "foo"
        param_keys = []

        subject.put(variable_segment, param_keys)

        expect(param_keys).to include(key_for_variable_segment)
      end
    end
  end

  describe "#get" do
    context "when segment is found" do
      context "and segment is fixed" do
        it "returns a node" do
          segment = "foo"
          param_keys = []
          param_values = []

          subject.put(segment, param_keys)

          result = subject.get(segment, param_values)

          expect(result).to be_kind_of(described_class)
        end

        it "does not update param_values" do
          segment = "foo"
          param_keys = []
          param_values = []

          subject.put(segment, param_keys)
          subject.get(segment, param_values)

          result = param_values

          expect(result).to be_empty
        end
      end

      context "and segment is variable" do
        it "returns a node" do
          variable_segment = ":foo"
          param_keys = []
          path_segment = "bar"
          param_values = []

          subject.put(variable_segment, param_keys)

          result = subject.get(path_segment, param_values)

          expect(result).to be_kind_of(described_class)
        end

        it "update param_values" do
          variable_segment = ":foo"
          param_keys = []
          path_segment = "bar"
          param_values = []

          subject.put(variable_segment, param_keys)
          subject.get(path_segment, param_values)

          result = param_values

          expect(result).to include("bar")
        end
      end
    end

    context "when segment is not found" do
      it "returns nil" do
        segment = "foo"
        param_keys = []
        path_segment = "bar"
        param_values = []

        subject.put(segment, param_keys)

        result = subject.get(path_segment, param_values)

        expect(result).to be_nil
      end
    end
  end

  describe "#leaf!" do
    context "when called" do
      it "returns a Leaf object" do
        segment = "foo"
        to = "target action"
        constraints = {}
        param_keys = []
        param_values = []

        subject.put(segment, param_keys).leaf!(param_keys, to, constraints)

        result = subject.get(segment, param_values).match(param_values)

        expect(result).to be_kind_of(Hanami::Router::Leaf)
      end
    end
  end

  describe "#match" do
    context "when @leaves collection is empty" do
      it "returns nil" do
        segment = "foo"
        param_keys = []
        param_values = []

        subject.put(segment, param_keys)

        result = subject.get(segment, param_values).match(param_values)

        expect(result).to be_nil
      end
    end

    context "when @leaves collection contains a match" do
      it "returns the matching leaf" do
        segment = "foo"
        to = "target action"
        constraints = {}
        param_keys = []
        param_values = []

        subject.put(segment, param_keys).leaf!(param_keys, to, constraints)
        leaf = subject.get(segment, param_values).match(param_values)

        result = leaf.to

        expect(result).to be("target action")
      end
    end
  end
end
