require "papyrus/consolidation/batch_callback"
require "papyrus/consolidation/transaction_callback"

module Papyrus
  module Consolidation
    class Batch
      class << self

        def start(**options, &block)
          if block.present?
            Papyrus.consolidate do
              options = options.merge(timeout: 3600, sync: false)

              datastore = Papyrus.papyrus_datastore.deep_dup

              parent_batch_id = Papyrus::Consolidation::Batch.sidekiq_batch_id
              batch = if parent_batch_id.present?
                        Sidekiq::Batch.new(parent_batch_id)
                      else
                        batch = Sidekiq::Batch.new
                        batch.description = "Papyrus consolidation batch: #{datastore.inspect}"
                        batch.on(:complete, Papyrus::Consolidation::BatchCallback, datastore.as_json) unless options[:sync] == true
                        Papyrus.add_thread_variables(bid: batch.bid)
                        batch
                      end

              result = nil
              batch.jobs do
                result = block.call
              end

              if options[:sync] == true
                timeout = options[:timeout] || 0
                if timeout > 0
                  end_time = Time.now + timeout.seconds
                  loop do
                    st = Sidekiq::Batch::Status.new(batch.bid)
                    break if st.deleted? || st.complete? || Time.now > end_time
                    sleep 1
                  rescue Sidekiq::Batch::NoSuchBatch
                    break
                  end
                end

                if ActiveRecord::Base.connection.transaction_open?
                  Papyrus::Consolidation::TransactionCallback.create(options.deep_dup.as_json)
                else
                  Papyrus.remove_datastore
                  Papyrus.print_consolidation(consolidation_id)
                end
              end

              result
            end
          end
        end

        def current(fallback_bid = Thread.current[:sidekiq_context]&.[](:bid))
          Thread.current[:sidekiq_batch] || (fallback_bid.present? ? Sidekiq::Batch.new(fallback_bid) : nil)
        rescue StandardError
          nil
        end

        def within_batch(fallback_bid = Thread.current[:sidekiq_context]&.[](:bid))
          cbatch = Thread.current[:sidekiq_batch] || (fallback_bid.present? ? Sidekiq::Batch.new(fallback_bid) : nil)
          if block_given? && cbatch.present?
            if Thread.current[:sidekiq_batch].nil?
              cbatch.jobs { yield }
            else
              yield
            end
          end
          cbatch
        rescue StandardError
          nil
        end

        def sidekiq_batch_id
          bid = nil
          context = Thread.current[:sidekiq_context]
          bid = Thread.current[:sidekiq_context][:bid] if context.present?
          bid
        end

        def escape(payload = nil)
          original_batch = Thread.current[:sidekiq_batch]
          original_batch_status = Thread.current[:sidekiq_batch_status]
          bid = payload.delete("bid") if payload && payload.key?("bid")

          Thread.current[:sidekiq_batch] = nil
          Thread.current[:sidekiq_batch_status] = nil
          yield
        ensure
          Thread.current[:sidekiq_batch] = original_batch
          Thread.current[:sidekiq_batch_status] = original_batch_status
          payload["bid"] = bid if payload && bid
        end

      end
    end
  end
end
