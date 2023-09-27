module Papyrus
  module Consolidation
    class Callback
      def complete(datastore)
        consolidation_id = datastore.dig('papyrus', 'consolidation_id')
        Papyrus.print_consolidation(consolidation_id) if consolidation_id.present?
      end

      def job_complete(job_id, datastore)
        # Do nothing
      end

    end
  end
end
