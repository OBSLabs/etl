module Etl
  module Etl::Workflow
    extend self

    # Workflow entry point
    def run(state=nil)
      call(state)
    end

    # Workflow to have the same interface as Proc.
    def call(state)
      state = state || default_state
      subject = @__workflow || @__steps
      raise ArgumentError.new("Workflow is not defined for module #{self.name}") unless subject
      subject.inject(state) do |s, workflow_or_lambda|
        workflow_or_lambda.call(s)
      end
    end

    protected

    # DSL Statement
    def step(*args,&block)
      @__steps ||= []
      @__steps << Proc.new(&block)
    end

    # DSL statement
    def initialize_with(&block)
      @__initialize_with = Proc.new(&block)
    end

    # DSL statement
    def workflow(*args)
      @__workflow = args
    end

    private
    def default_state
      (@__initialize_with || Proc.new{}).call
    end
  end
end
