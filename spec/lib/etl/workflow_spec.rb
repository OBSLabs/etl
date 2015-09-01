require 'spec_helper'

describe Etl::Workflow do
  let(:mod) do
    Module.new do
      extend Etl::Workflow
    end
  end

  describe "#[]" do
    context 'when step defined' do
      it do
        mod.step(:foo) {}
        expect(mod[:foo]).to respond_to(:call)
      end
    end

    context 'when step undefined' do
      it do
        expect(mod[:foo]).to be_nil
      end
    end
  end

  describe ".call" do
    it 'should support Proc interface' do
      expect(mod).to respond_to(:call)
    end
  end

  describe ".run" do
    context "when no steps & no workflow" do
      it do
        expect( mod.run(1) ).to eq(1)
      end
    end

    context "when there is a one step" do
      it "handles invariant step" do
        mod.step { 1 }
        expect(mod.run).to eq(1)
      end

      it "uses previous state" do
        mod.step {|state| state + 1 }
        expect(mod.run(1)).to eq(2)
      end
    end

    context "when there is a pipe" do
      it  do
        mod.step(:inc) { |s| s + 1 }
        mod.step(:mult) { |s| s * 5 }

        expect(mod.run(1)).to eq( (1+1) * 5 )
      end
    end
  end

  describe ".update" do
    it "updates hash value" do
      mod.update(:foo) { |s| :bar }
      expect(mod.run({})).to eq(foo: :bar)
    end

    it "updates attribute" do
      klass = Class.new do
        attr_accessor :foo
      end
      mod.update(:foo) { :bar }
      expect(mod.run(klass.new).foo).to eq(:bar)
    end
  end


  describe ".initialize_with" do
    context "when no default given" do
      it do
        mod.step{|s| s}

        expect(mod.run).to be_nil
      end
    end

    context "when default given" do
      it do
        mod.initialize_with { :foo }
        mod.step {|s| s }

        expect(mod.run).to eq(:foo)
      end
    end
  end
end
