module Etl
  module Etl::Workflow
    extend self

    # Workflow entry point
    #
    # @param (see #call)
    def run(state=nil)
      call(state)
    end

    # Workflow to have the same interface as Proc.
    # Execute workflow by sequently running nested workflows (first)
    # and steps (second)
    #
    # @param state [Object] initial state of the workflow.
    # @return [Object] that represent final state of the workflow
    def call(state)
      state = state || default_state
      subject = workflows + steps.values
      subject.inject(state) do |s, workflow_or_lambda|
        workflow_or_lambda.call(s)
      end
    end

    #protected

    # DSL Statement
    #
    # Defines a step in ETL process.
    # Step has an alias 'step_:name'
    #
    # @param name [Symbol] the name of the step.
    # @return self
    # @yieldparam state [Object] the current state
    # @yieldreturn [Object] the next iteration of the state
    def step(name=:no_name, *args,&block)
      steps[name] = Proc.new(&block)
      method_name = [:step,name].join('_')
      define_method(method_name, &block)
      extend self # necessary add method definition
    end

    # DSL Statement
    #
    # Defines a step that change the state
    #
    # @param attr [Symbol] attribute to change.
    # @param (see #step)
    def update(attr,*args, &block)
      step("def_#{attr}", args) do |state|
        value = yield(state)
        method_name = "#{attr}="
        if state.respond_to?(method_name)
          state.send(method_name,value)
        else
          state[attr] = value
        end
        state
      end
    end

    # Defines a side effect step. i.e. Dumping state into the file.
    def push(name = nil, *args, &block)
      step("push_#{name}",args) do |state|
        yield(state)
        state
      end
    end

    def workflows
      @__workflow ||= []
    end

    def steps
      @__steps ||= {}
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
