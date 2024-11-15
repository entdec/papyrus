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
        papyrus_datastore = job_payload['___papyrus_datastore']

        if papyrus_datastore
          Papyrus.add_thread_variables(**papyrus_datastore) unless Papyrus.consolidate?

          in_batch = job_payload["bid"]
          unless in_batch
            result = nil
            nested_batch = Sidekiq::Batch.new
            nested_batch.jobs { result = yield }
            return result
          end
        end

        yield
      ensure
        Papyrus.remove_datastore
      end
    end

    class SidekiqClientServerMiddleware
      include Sidekiq::ServerMiddleware

      def call(job_instance, job_payload, queue)
        consolidating = Papyrus.consolidate? || job_payload['___papyrus_datastore']

        if consolidating && job_instance.class.name != "Papyrus::EventJob"
          Sidekiq::Batch::Server.new.call(job_instance, job_payload, queue)
        else
          yield
        end
      end

    end

  end
end
