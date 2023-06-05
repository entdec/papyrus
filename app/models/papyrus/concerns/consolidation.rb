module Papyrus
  module Concerns
    module Consolidation
      extend ActiveSupport::Concern

      included do

        attr_writer :papyrus_datastore

        def papyrus_datastore
          @papyrus_datastore ||= {}
        end

        def serialize
          super.merge(papyrus_datastore: papyrus_datastore)
        end

        def deserialize(job_data)
          super
          self.papyrus_datastore = job_data['papyrus_datastore']
        end

        before_enqueue do |job|
          job.papyrus_datastore[:consolidation_id] = Papyrus.consolidation_id
        end

        around_enqueue do |job, block|
          if job.papyrus_datastore[:consolidation_id].present?
            Papyrus.add_thread_variables(consolidation_id: job.papyrus_datastore[:consolidation_id])
          end

          block.call

          Papyrus.remove_thread_variables(:consolidation_id) unless Papyrus.consolidation_root_thread?
        end
      end

    end
  end
end
