module Papyrus
  module Consolidation
    class SidekiqClientMiddleware
      include Sidekiq::ClientMiddleware

      # @param [String, Class] job_class_or_string the class or string representation
      #    of the class of the job being queued
      # @param [Hash] job_payload the full job payload
      #   * @see https://github.com/sidekiq/sidekiq/wiki/Job-Format
      # @param [String] queue the name of the queue the job was pulled from
      # @param [ConnectionPool] redis_pool the redis pool
      # @return [Hash, FalseClass, nil] if false or nil is returned,
      #   the job is not to be enqueued into redis, otherwise the block's
      #   return value is returned
      # @yield the next middleware in the chain or the enqueuing of the job
      def call(job_class_or_string, job_payload, queue, redis_pool)
        if Papyrus.papyrus_datastore.present? && job_class_or_string.to_s != "Sidekiq::Batch::Empty"
          job_payload["___papyrus_datastore"] = Papyrus.papyrus_datastore.deep_dup.as_json
        end

        if Thread.current[:sidekiq_batch].present? && job_class_or_string.to_s != "Sidekiq::Batch::Empty" && job_payload["bid"] == Thread.current[:sidekiq_batch]&.bid
          yield
          false
        else
          yield
        end
      end
    end
  end
end
