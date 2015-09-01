module Etl
  module Topology
    extend self

    def of(workflow)
      workflow.workflows.map do |mod|
        of(mod).map do |d|
          sep = d.include?("#") ? '::' : '#'
          [mod.name,d].join(sep)
        end
      end.flatten + workflow.procs.keys.map(&:to_s)
    end
  end
end
