module Papyrus
  module Consolidation
    class BatchCallback

      def on_complete(status, options)
        consolidation_id = options['consolidation_id']
        return unless consolidation_id

        if ActiveRecord::Base.connection.transaction_open?
          ActiveRecord::Base.connection.add_transaction_record(Papyrus::Consolidation::TransactionCallback.new(consolidation_id: consolidation_id))
        else
          Papyrus.remove_datastore
          Papyrus.print_consolidation(consolidation_id)
        end
      end

      def on_success(status, options)

      end

      def on_failure(status, options)

      end

    end
  end
end
