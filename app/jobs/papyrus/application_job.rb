module Papyrus
  class ApplicationJob
    include Sidekiq::Job
    prepend Auxilium::Concerns::SidekiqCallbacks
    # discard_on ActiveJob::DeserializationError
    include Servitium::JobMetrics
  end
end
