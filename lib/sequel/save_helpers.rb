module Sequel
  module Plugins
    module SaveHelpers
      module InstanceMethods
        def save!(*columns)
          opts = columns.last.is_a?(Hash) ? columns.pop : {}
          opts.merge!(raise_on_failure: true)
          save(*columns, opts)
        end
      end
    end
  end
end