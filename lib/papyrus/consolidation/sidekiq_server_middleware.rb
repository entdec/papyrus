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

        begin
          if Papyrus.papyrus_datastore.empty? && papyrus_datastore.present?
            Thread.current[:papyrus_master_job] ||= job_instance.object_id
            Papyrus.add_thread_variables(**papyrus_datastore)

            # If we are NOT within a Sidekiq batch, we need to prepend the batch class methods.w
            # We don't want to put yield in a batch directly as it might not be the last middleware in the chain.
            if Thread.current[:sidekiq_batch].blank?
              bid = (Thread.current[:sidekiq_context][:bid] if Thread.current[:sidekiq_context].present?)
              job_instance.class.prepend(Papyrus::Consolidation::BatchClassMethods) if bid.present?
            end
          end

          # Go on to the next middleware in the chain or the worker `perform` method
          yield
        rescue StandardError => e
          Papyrus.logger.error e.message
        ensure
          if Thread.current[:papyrus_master_job] == job_instance.object_id
            Papyrus.remove_datastore
            Thread.current[:papyrus_master_job] = nil
          end
        end

      end

    end

    module BatchClassMethods
      def perform(*args)
        bid = (Thread.current[:sidekiq_context][:bid] if Thread.current[:sidekiq_context].present?)

        result = nil
        if bid.present? && Thread.current[:sidekiq_batch].blank?
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
