module Etl
  module Workflow
    extend self
    def run(state = nil)
      @workflow.inject(state) do |state,stage|
        stage.run(state)
      end
    end

    protected
    def workflow(*args)
      @workflow = args
    end
  end
end

