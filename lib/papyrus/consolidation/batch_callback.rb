module Papyrus
  module Consolidation
    class BatchCallback

      def on_complete(status, options)
        options = {} unless options.is_a?(Hash)
        options = options.with_indifferent_access
        return unless options["consolidation_id"].present?
        consolidation_id = options["consolidation_id"]

        if ActiveRecord::Base.connection.transaction_open?
          ActiveRecord::Base.connection.add_transaction_record(Papyrus::Consolidation::TransactionCallback.new(options))
        else
          Papyrus.remove_datastore
          Papyrus.print_consolidation(consolidation_id, options)
        end
      end

      def on_success(status, options) end

      def on_failure(status, options) end

    end
  end
end
