module Papyrus
  class SidekiqConsolidationJob < ApplicationJob

    def perform(consolidation_id)
      Papyrus.start_consolidation(consolidation_id)

      batch = Sidekiq::Batch.new
      batch.description = "Papyrus::ConsolidationJob (#{consolidation_id})"

      batch.on(:complete, self.class, consolidation_id: Thread.current[:papyrus_consolidation_id])
      batch.jobs do
        yield if block_given?
      end
    end

    def on_complete(status, options)
      consolidation_id = options[:consolidation_id]
      return if consolidation_id.blank?

      Papyrus::ConsolidationSpoolJob.perform_later(consolidation_id)
    end

  end
end
