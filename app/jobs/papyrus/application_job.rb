module Papyrus
  class ApplicationJob
    include Sidekiq::Job
    prepend SidekiqCallbacks
    # discard_on ActiveJob::DeserializationError
    include Papyrus::Consolidation
  end
end
