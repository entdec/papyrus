module Papyrus
  module Concerns
    module Consolidation
      extend ActiveSupport::Concern

      included do

        before_enqueue do |job|
          papyrus_consolidation_id = Thread.current[:papyrus_consolidation_id]

          if papyrus_consolidation_id.present?
            if job.arguments.last&.respond_to?(:key?)
              unless job.arguments.last.key?(:papyrus_consolidation_id)
                job.arguments.last[:papyrus_consolidation_id] = papyrus_consolidation_id
              end
            else
              job.arguments.push({ papyrus_consolidation_id: papyrus_consolidation_id })
            end
          end
        end

        around_enqueue do |job, block|
          arg = job.arguments.last
          papyrus_consolidation_id = if arg.respond_to?(:key?) && arg[:papyrus_consolidation_id].present?
                                       arg[:papyrus_consolidation_id]
                                     end
          if papyrus_consolidation_id.present?
            Thread.current[:papyrus_consolidation_id] = papyrus_consolidation_id
            job.arguments.delete_at(job.arguments.size - 1) if arg.size == 1
          end

          block.call

          Thread.current[:papyrus_consolidation_id] = nil if papyrus_consolidation_id.present?
        end

      end
    end
  end
end
