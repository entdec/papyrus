module Papyrus
  class ApplicationJob
    include Sidekiq::Job
    prepend Auxilium::Concerns::SidekiqCallbacks
    # discard_on ActiveJob::DeserializationError
    include Papyrus::JobPerformLogger

    sidekiq_retry_in do |count, exception, jobhash|
      case exception
      when Papyrus::UpdatePrintNodeInformationException
        :kill
      end
    end
  end
end
