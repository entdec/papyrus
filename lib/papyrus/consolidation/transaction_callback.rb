module Papyrus
  module Consolidation
    class TransactionCallback
      def initialize(variables = {})
        variables = {} unless variables.is_a?(Hash)
        @variables = variables.with_indifferent_access
        @consolidation_id = @variables[:consolidation_id]
      end

      def register
        ActiveRecord::Base.after_commit on: :any do
          perform_consolidation_spool_job
        end
      end

      def perform_consolidation_spool_job
        Papyrus::ConsolidationSpoolJob.perform_sync(@consolidation_id)
      end

      def self.create(variables)
        new(variables).tap(&:register)
      end
    end
  end
end
