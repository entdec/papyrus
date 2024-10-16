module Papyrus
  module Consolidation
    class SidekiqServerMiddleware
      include Sidekiq::ServerMiddleware

      # @param [Object] job_instance the instance of the job that was queued
      # @param [Hash] job_payload the full job payload
      #   * @see https://github.com/sidekiq/sidekiq/wiki/Job-Format
      # @param [String] queue the name of the queue the job was pulled from
      # @yield the next middleware in the chain or worker `perform` method
      # @return [Void]
      def call(job_instance, job_payload, queue)
        papyrus_datastore = (job_payload['$papyrus_datastore'] if job_payload['class'] != 'Sidekiq::Batch::Empty')

        if Papyrus.papyrus_datastore.empty? && papyrus_datastore.present?
          Thread.current[:papyrus_master_job] ||= job_instance.object_id
          Papyrus.add_thread_variables(**papyrus_datastore)

          # If we are NOT within a Sidekiq batch, we need to prepend the batch class methods to pick up new jobs queued.
          # We don't want to put yield in a batch directly as it might not be the last middleware in the chain.
          if Thread.current[:sidekiq_batch].blank?
            bid = (Thread.current[:sidekiq_context][:bid] if Thread.current[:sidekiq_context].present?)
            prepend_class(job_instance, Papyrus::Consolidation::BatchClassMethods) if bid.present?
          end
        end

        yield
      ensure
        if Thread.current[:papyrus_master_job] == job_instance.object_id
          Papyrus.remove_datastore
          Thread.current[:papyrus_master_job] = nil
        end
      end

      # Prepend methods to the singleton class; a singleton class is instance bound.
      def prepend_class(instance, klass)
        instance_klass = instance&.singleton_class
        return unless instance_klass
        instance_klass.prepend(klass) if instance_klass.ancestors.exclude?(klass)
      end

    end

    module BatchClassMethods
      def perform(*args)
        bid = (Thread.current[:sidekiq_context][:bid] if Thread.current[:sidekiq_context].present?)

        result = nil
        if bid.present? && Thread.current[:sidekiq_batch].blank?
          # Run perform in batch context so we ca pickup any new jobs queued for recursive consolidation
          Sidekiq::Batch.new(bid).jobs do
            result = super(*args)
          end
        else
          result = super(*args)
        end
        result
      end
    end

  end
end
