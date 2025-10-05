# frozen_string_literal: true

require "hanami/router/leaf"

RSpec.describe Hanami::Router::Leaf do
  let(:subject) { described_class.new(param_keys, to, constraints) }
  let(:to) { "test proc" }

  describe "#initialize" do
    let(:param_keys)  { [] }
    let(:constraints) { {} }

    it "returns a #{described_class} instance" do
      result = subject

      expect(result).to be_kind_of(described_class)
    end

    it "sets :to attribute to target action" do
      result = subject.to

      expect(result).to eq("test proc")
    end

    it "sets :params attribute to nil" do
      result = subject.params

      expect(result).to be_nil
    end
  end

  describe "#match" do
    let(:param_keys) { ["variable"] }
    let(:param_values) { ["value"] }

    context "with no constraints" do
      let(:constraints) { {} }

      it "returns true" do
        result = subject.match(param_values)

        expect(result).to be_truthy
      end

      it "sets captured params" do
        leaf = subject
        leaf.match(param_values)

        result = leaf.params

        expect(result).to eq({"variable" => "value"})
      end
    end

    context "with valid constraint" do
      let(:constraints) { {variable: /\w+/} }

      it "returns true" do
        result = subject.match(param_values)

        expect(result).to be_truthy
      end

      it "sets captured params" do
        leaf = subject
        leaf.match(param_values)

        result = leaf.params

        expect(result).to eq({"variable" => "value"})
      end
    end

    context "with invalid constraint" do
      let(:constraints) { {variable: /\d+/} }

      it "returns false" do
        result = subject.match(param_values)

        expect(result).to be_falsey
      end
    end
  end
end
