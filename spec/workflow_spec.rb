require File.join(File.dirname(__FILE__), "spec_helper")


describe Etl::Workflow do

  describe ".call" do
    it 'should support Proc interface' do
      mod = Module.new do
        extend Etl::Workflow
      end
      expect(mod).to respond_to(:call)
    end
  end

  describe ".run" do
    context "when no steps & no workflow" do
      it do
        mod  =  Module.new do
          extend Etl::Workflow
        end
        expect{ mod.run }.to raise_error
      end
    end

    context "when there is a one step" do
      it "handles invariant step" do
        mod = Module.new do
          extend Etl::Workflow
          step do
            1
          end
        end

        expect(mod.run).to eq(1)
      end

      it "uses previous state" do
        mod = Module.new do
          extend Etl::Workflow
          step do |state|
            state + 1
          end
        end
        expect(mod.run(1)).to eq(2)
      end
    end

    context "when there is a pipe" do
      it  do
        mod = Module.new do
          extend Etl::Workflow
          step do |state|
            state + 1
          end

          step do |state|
            state * 5
          end
        end
        expect(mod.run(1)).to eq( (1+1) * 5 )
      end
    end
  end

  describe ".update" do
    it "updates hash value" do
      mod = Module.new do
        extend Etl::Workflow
        update :foo do |state|
          :bar
        end
      end
      expect(mod.run({})).to eq(foo: :bar)
    end

    it "updates attribute" do
      klass = Class.new do
        attr_accessor :foo
      end
      mod = Module.new do
        extend Etl::Workflow
        update :foo do |state|
          :bar
        end
      end
      expect(mod.run(klass.new).foo).to eq(:bar)
    end
  end


  describe ".initialize_with" do
    context "when no default given" do
      it do
        mod = Module.new do
          extend Etl::Workflow
          step do |state|
            state
          end
        end

        expect(mod.run).to be_nil
      end
    end

    context "when default given" do
      it do
        mod = Module.new do
          extend Etl::Workflow
          initialize_with do
            :foo
          end
          step do |state|
            state
          end
        end

        expect(mod.run).to eq(:foo)
      end
    end
  end
end
