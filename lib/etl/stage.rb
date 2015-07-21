module Etl
  module Etl::Stage
    extend self

    def run(state = nil)
      state = state || default_state
      @steps.inject(state) do |s,e|
        e.call(s)
      end
    end

    protected
    def step(*args,&block)
      @steps ||= []
      @steps << Proc.new(&block)
    end

    def initialize_with(&block)
      @initialize_with = Proc.new(&block)
    end

    def default_state
      (@initialize_with || Proc.new{}).call
    end
  end
end
