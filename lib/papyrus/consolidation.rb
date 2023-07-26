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
          @papyrus_datastore ||= HashWithIndifferentAccess.new
        end

        def serialize
          super.merge!({ 'papyrus_datastore' => papyrus_datastore })
        end

        def deserialize(job_data)
          super
          papyrus_datastore.merge!(job_data['papyrus_datastore']) if job_data['papyrus_datastore']
        end

        before_enqueue do |job|
          job.papyrus_datastore = Papyrus.papyrus_datastore.merge(async: true) if Papyrus.consolidate?
        end

        around_perform do |job, block|
          job.papyrus_datastore[:async] ||= false

          update_thread_variables = job.papyrus_datastore[:consolidation_id].present? && !Papyrus.consolidate?

          begin
            Papyrus.add_thread_variables(**job.papyrus_datastore) if update_thread_variables

            block.call
          ensure
            Papyrus::Consolidation.remove_all_thread_variables if update_thread_variables
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

      module ServiceClassMethods

        def perform(*args)
          return super(*args) if Papyrus.consolidate?

          Papyrus::Consolidation.generate_thread_variables
          super(*args)
        end

        def perform!(*args)
          return super(*args) if Papyrus.consolidate?

          Papyrus::Consolidation.generate_thread_variables
          super(*args)
        end

        def perform_async(*args)
          return super(*args) if Papyrus.consolidate?

          begin
            Papyrus::Consolidation.generate_thread_variables
            super(*args)
          ensure
            Papyrus::Consolidation.remove_all_thread_variables
          end
        end
      end

      def Service.included(base)
        base.class_eval do
          extend ServiceClassMethods

          after_async_success do
            if Papyrus.consolidate? && Papyrus.papyrus_datastore[:async] == true
              begin
                Papyrus.print_consolidation(Papyrus.consolidation_id)
              ensure
                Papyrus::Consolidation.remove_all_thread_variables
              end
            end
          end

          after_commit do
            if Papyrus.consolidate? && Papyrus.papyrus_datastore[:async] == false
              begin
                Papyrus.print_consolidation(Papyrus.consolidation_id)
              ensure
                Papyrus::Consolidation.remove_all_thread_variables
              end
            end
          end

          after_failure do
            Papyrus::Consolidation.remove_all_thread_variables
          end

        end
      end

    end

    def self.remove_all_thread_variables
      Papyrus.remove_thread_variables(:consolidation_id, :async)
    end

    def self.generate_thread_variables
      Papyrus.add_thread_variables(consolidation_id: SecureRandom.uuid)
    end

  end
end
