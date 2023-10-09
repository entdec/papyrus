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
        Papyrus.papyrus_datastore[:job_count] ||= 0
        Papyrus.papyrus_datastore[:job_count] = Papyrus.papyrus_datastore[:job_count] + 1

        papyrus_datastore = job_payload['$papyrus_datastore']
        begin
          if papyrus_datastore.present?
            Papyrus.add_thread_variables(**job_payload['$papyrus_datastore'])

            bid = if Thread.current[:sidekiq_context].present?
                    Thread.current[:sidekiq_context][:bid]
                  end
            if bid.present?
              job_instance.class.prepend(Papyrus::Consolidation::BatchClassMethods)
            end
          end
          yield
        rescue => ex
          puts ex.message
        end

      ensure
        if Papyrus.papyrus_datastore.present?
          Papyrus.papyrus_datastore[:job_count] = Papyrus.papyrus_datastore[:job_count] - 1
          Papyrus.remove_datastore if Papyrus.papyrus_datastore[:job_count] == 0
        end
      end
    end

    module BatchClassMethods
      def perform(*args)
        bid = if Thread.current[:sidekiq_context].present?
                Thread.current[:sidekiq_context][:bid]
              end

        result = nil
        if bid.present?
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
