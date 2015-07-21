This gem provide a DSL to describe Extract Transform Load Workflows.

DSL has three abstractions
* Stage
* Step
* Workflow

Stage is module that chains one or several steps together and return their result. Result of the first step passes to the second step etc. Value of the last step is the result of the whole chain.
```
module Test
  extend Etl::Stage
  3.times do 
    step do |i|
      puts i
      i + 1
    end
  end
end
Test.run(1)
```
yields: 
```
1
2
3
```
and returns `3`


Step is operation over the copy of the state passed to the block and always return the latest version of the state.
step do |state|
  state[:data] = File.read('foo.bar')
  state
end
NOTE: state received a clonned state and step block should always return the actual state value.

Workflow is a sequence of Stage and state passes through each stage.

It's important to have multiple stages to make sure that each one has it's own responsibility. i.e. Extract, Transform or Load.
i.e.
Extract could be responsible of pulling data from multiple sources into the state
Transform transforming data
Load creating records in database or uploading on s3.


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
