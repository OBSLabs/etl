This gem provide a DSL to describe Extract Transform Load Workflows.



```
require 'rubygems'
require 'etl'

module SomeEtl
  extend Etl::Workflow

  module Extract
    extend Etl::Stage

    initialize_with do
      {}
    end

    step do |state|
      state[1] = 1
      state
    end

    step do |state|
      state[2] = 3
      state
    end
  end

  module Transform
    extend Etl::Stage

    step do |state|
      state[3] = 1
      state
    end

    step do |state|
      state[:bar] = 3
      state
    end
  end

  workflow Extract,Transform
end

puts SomeEtl.run.inspect
```
