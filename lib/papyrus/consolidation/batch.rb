require "papyrus/consolidation/batch_callback"
require "papyrus/consolidation/transaction_callback"

module Papyrus
  module Consolidation
    class Batch
      class << self

        def start(&block)
          Papyrus.papyrus_datastore[:job_count] ||= 0
          Papyrus.papyrus_datastore[:job_count] = Papyrus.papyrus_datastore[:job_count] + 1

          if block.present?
            Papyrus.consolidate do
              datastore = Papyrus.papyrus_datastore.slice(:consolidation_id, :group_id, :purposes)

              parent_batch_id = Papyrus::Consolidation::Batch.sidekiq_batch_id
              batch = if parent_batch_id.present?
                        Sidekiq::Batch.new(parent_batch_id)
                      else
                        batch = Sidekiq::Batch.new
                        batch.description = "Papyrus consolidation batch: #{datastore.inspect}"
                        batch.on(:complete, Papyrus::Consolidation::BatchCallback, datastore)
                        Papyrus.add_thread_variables(bid: batch.bid)
                        batch
                      end

              result = nil
              batch.jobs do
                result = block.call
              end
              result
            end
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
