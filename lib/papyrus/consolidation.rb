module Papyrus
  module Consolidation

    #
    # This module should be included in the root application job class in order
    # for the consolidation to work properly with asynchronous ActiveJobs.
    #
    def Consolidation.included(base)
      base.class_eval do
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

          begin
            block.call
          ensure
            Papyrus.remove_thread_variables(:consolidation_id) unless Papyrus.consolidation_root_thread?
          end
        end
      end

    end

    #
    # This module can be included in any Servitium::Service in order to
    # automatically start consolidation when the service called and end consolidation
    # after commit.
    #
    module Service
      def Service.included(base)
        base.class_eval do
          after_commit { Papyrus.end_consolidation }
          after_failure { Papyrus.end_consolidation }

          def initialize(*args)
            Papyrus.start_consolidation
            super(*args)
          end

        end
      end

    end
  end
end
