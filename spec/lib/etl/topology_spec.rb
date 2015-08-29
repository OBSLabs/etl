require 'spec_helper'


describe Etl::Topology do
  let(:mod) do
    Module.new do
      extend Etl::Workflow
      a = Module.new do
        def name
          "TheModule"
        end
        extend Etl::Workflow
        step(:baz){}
      end
      step(:foo){}
      step(:bar){}
      workflow a
    end
  end
  context "#of" do
    it do
      expect(Etl::Topology.of(mod)).to eq(['TheModule#baz', 'foo', 'bar'])
    end
  end
end
