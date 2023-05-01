module Papyrus
  class ConsolidationJob < ApplicationJob

    def perform(consolidation_id, block)
      Papyrus.start_consolidation(consolidation_id)
      ActiveRecord::Base.transaction(requires_new: true) do
        #  ActiveRecord::Base.connection.current_transaction.add_record(self)
        block.call
      end
      Papyrus.end_consolidation
    end

  end
end
