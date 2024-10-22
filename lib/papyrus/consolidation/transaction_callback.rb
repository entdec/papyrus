module Papyrus
  module Consolidation
    class TransactionCallback
      def initialize(variables = {})
        @connection = ActiveRecord::Base.connection
        variables = {} unless variables.is_a?(Hash)

        @variables = variables.with_indifferent_access
        @consolidation_id = @variables[:consolidation_id]
      end

      # rubocop: disable Naming/PredicateName
      def has_transactional_callbacks?
        true
      end

      # rubocop: enable Naming/PredicateName

      def before_committed!(*)
        # noop
      end

      def trigger_transactional_callbacks?
        true
      end

      def committed!(*)
        print_consolidation(@consolidation_id) if @consolidation_id.present?
      end

      def rolledback!(*)
        # noop
      end

      # Required for +transaction(requires_new: true)+
      def add_to_transaction(*)
        @connection.add_transaction_record(self)
      end

      def print_consolidation(consolidation_id)
        Papyrus::ConsolidationSpoolJob.perform_async(consolidation_id)
      end

    end
  end
end
