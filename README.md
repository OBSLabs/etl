This gem provide a DSL to describe Extract Transform Load Workflows.

Means of abstraction.
* Workflow

Means of Combination
* Workflow might consist of steps
* Workflow might consist of workflows


Designed with a regard to:
Single Responsiblity. Workflow, Stage and step have one responsibility
High cohision. Stages and steps communicate with each other via contract
Low coupling. Stages and steps are not aware about each other. Each stage could be used independently.
Modularity. Each stage has well defined interface which is a great subject to test.
Pattern. The one way to implement ETL. Valuable in a large projects.


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


Step is operation over the copy of the state object passed to the block and returning the latest the state object.
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


```ruby
require 'rubygems'
require 'etl'

module SomeEtl
  extend Etl::Workflow

  class State
    attr_accessor :users, :contracts, :invoices, :groups
  end

  module Extract
    extend Etl::Stage

    initialize_with do
      State.new
    end

    step 'find users' do |state|
      state.users = User.find(:all)
      state
    end

    step 'find contracts' do |state|
      state.contracts = Contract.active.where(user_id: state.users.map(&:id))
      state
    end
  end

  module Transform
    extend Etl::Stage

    step 'Caclulate invoices' do |state|
      state.invoices = calculate(state.users, state.contracts)
      state
    end

    step 'Group invoices by user' do |state|
      state.groups = state.invoices.group_by(&:user_id)....
      state
    end

    def caclulate(users, contracts)
      # <scary logic goes here>
    end
  end

  module Load
    extend Etl::Stage

    step 'Persist to db' do |state|
      Invoice.transaction do
        state.invoices.each do |invoice|
          invoice.save!
        end
      end
    end

    step 'Send notifications' do |state|
      state.groups.each do |user, invoice|
        UserMailer.deliver_invoice(user, invoice)
      end
    end

  workflow Extract,Transform, Load
end

puts SomeEtl.run.inspect
```



