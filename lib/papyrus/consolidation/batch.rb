module Papyrus
  module Consolidation
    class Batch
      class << self

        def start(&block)
          Papyrus.papyrus_datastore[:job_count] ||= 0
          Papyrus.papyrus_datastore[:job_count] = Papyrus.papyrus_datastore[:job_count] + 1

          if block.present?
            consolidation_id = Papyrus.consolidation_id
            if consolidation_id.blank?
              consolidation_id = SecureRandom.urlsafe_base64(16)
              Papyrus.add_thread_variables(consolidation_id: consolidation_id)
            end

            parent_batch_id = Papyrus::Consolidation::Batch.sidekiq_batch_id
            batch = if parent_batch_id.present?
                      Sidekiq::Batch.new(parent_batch_id)
                    else
                      batch = Sidekiq::Batch.new
                      batch.description = "Papyrus consolidation batch: #{consolidation_id}"
                      batch.on(:complete, Papyrus::Consolidation::BatchCallback, consolidation_id: consolidation_id)
                      Papyrus.add_thread_variables(bid: batch.bid)
                      batch
                    end

            batch.jobs(&block)
          end
        ensure
          if Papyrus.papyrus_datastore.present?
            Papyrus.papyrus_datastore[:job_count] = Papyrus.papyrus_datastore[:job_count] - 1
            Papyrus.remove_datastore if Papyrus.papyrus_datastore[:job_count] == 0
          end
        end

        def sidekiq_batch_id
          bid = nil
          context = Thread.current[:sidekiq_context]
          bid = Thread.current[:sidekiq_context][:bid] if context.present?
          bid
        end

      end
    end
  end
end
