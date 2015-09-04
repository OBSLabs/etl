## Welcome to Virool Etl

Virool Etl is a library that includes everything needed to solve complex data transformation inside ruby application according to OOP best practices.

The basic idea behind it is to separate transformation state and stateless transforming operations (workflow).
Workflow starts with a initial state (injected from outside) and incrementally fill the state following throughout steps.

Another idea is that workflows are composable. A typical approach is to have one workflow to extact data, another to transform them and the last one load data to external device(persist) (ETL).

Virool Etl provides an simple and yet universal DSL to describe workflow and the result code is linear and easy to understand.

This gem is super lightweight (just about 100 LOC) and does not affect the performance of the host application.

## Getting Started

Add the following code to Gemfile
```ruby
gem 'etl', :git => 'git://github.com/OBSLabs/etl.git'
```
and run `bundle install`

Now `Etl::Workflow` module is available in the application.

The next step is create a brand new workflow.
```ruby
module MyWorkflow
  extend Etl::Workflow
  step do |x|
    x + 10
  end
end
```

To eval workflow: `MyWorkflow.run(32) #=> 42 `

## How it works

Workflow is a sequential set of neccessary & sufficient operations to load the data into the end target.
Workflow is stateless and state is passed from one step/workflow to another. The root workflow defines the initial state.
Workflow is a stand alone component that has a single entry point (inital state), set of operations to accomplish the end goal.
set of operations could be grouped into 3 parts.

Part | Responsibility | Typical actions
:---|:---|:---
Extract | Extracts data from the source system, normalizes it, and combines it. | SQL select, read file, HTTP GET request, S3 read, redis read, group array by ID, map hash into object.
Transform | Transforms extracted data according end target format. | map, reduce, transform
Load | Load data into the target system. | SQL insert/update/delete, write file, HTTP POST request, S3 write, redis write

None of the parts know about each other and the workflow is something that conduct communication between them.
Each part consists of one or several steps which are mutually independend and data fall from one step into another.

## Composing steps to make workflow
A step is an atomic part of a workflow. There can be any number of steps in a workflow. Each step is a stateless ruby block that receives a state object as a single argument and returns a new version of the state.
A workflow is evaluated by sequentially evaluating each of its steps:
* Take the initial value
* Run the first step with initial value as its state.
* Run the second step with the value that the first step returned as its state.
* ...
* The result of the last step is the result of the Workflow.

```ruby
step :a do |s|
...
end

step :b do |s|
...
end

step :c do |s|
...
end
```
is an equivalent of `c(b(a(...)))` or in clojure `(->> ... (a) (b) (c))`


## Composing workflows
Workflow might be a composition of serveral workflows. In this case workflow behave the same way as a regular step.

```ruby
module Workflow
  module A
  ...
  end

  module B
  ...
  end

  module C
  ...
  end
  workflow A, B, C
end
```
is equvalent of `C.call(B.call(A.call)))`
The root workflow is responsible for definition of the initial state and providing a clear entry point (public interface).

## Incremental state
State is an object that goes into the step and the step returns the next value of state (very similar to monad).
State can be mutable or immutable.
``` ruby
# Immutable, merge returns a new hash.
step :foo do |state|
  state.merge({foo: :bar})
end

# Mutable
step :foo do |state|
  state[:foo] = :bar
  state
end
```

## Typical operations
##### Set state attribute
```ruby
step do |state|
  state.foo = User.find(:all)
  state
end
```
is equivalent to:
```ruby
update :foo do |state|
  User.find(:all)
end
```

##### Perform side effect operation
```ruby
step do |state|
  S3.upload(state.foo)
  state
end
```
is equivalent to:
```ruby
push do |state|
  S3.upload(state.foo)
end
```

## Testing
Workflow has a "#[]" accessor to steps that returns a Proc so the step can be tested as regular ruby method:
```ruby
module Foo
  step :inc do |state|
    state + 1
  end
end
```

could be tested with:
```ruby
...
expect(Foo[:inc].call(5)).to eq(6)
...
```
As long each step is using only a trivial portion of state it's very simple to mock it. That's very helpful when testing transformation logic without any external adapter.



## Example workflow

```ruby
require 'etl'

module SomeEtl
  extend Etl::Workflow

  class State
    attr_accessor :users, :contracts, :invoices, :groups
  end

  module Extract
    extend Etl::Workflow

    update :users do |state|
      User.find(:all)
    end

    update :contracts do |state|
      Contract.active.where(user_id: state.users.map(&:id))
    end
  end

  module Transform
    extend Etl::Workflow

    update :invoices do |state|
      calculate(state.users, state.contracts)
    end

    update :groups do |state|
      state.invoices.group_by(&:user_id)....
    end

    def caclulate(users, contracts)
      # <scary logic goes here>
    end
  end

  module Load
    extend Etl::Workflow

    push 'Persist to db' do |state|
      Invoice.transaction do
        state.invoices.each do |invoice|
          invoice.save!
        end
      end
    end

    push 'Send notifications' do |state|
      state.groups.each do |user, invoice|
        UserMailer.deliver_invoice(user, invoice)
      end
    end
  end
  workflow Extract,Transform, Load
end

puts SomeEtl.run(SomeEtl::State.new).inspect
```

## License

Virool Etl is released under the [MIT License](http://opensource.org/licenses/MIT).

