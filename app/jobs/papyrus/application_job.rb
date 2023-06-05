module Papyrus
  class ApplicationJob < ActiveJob::Base
    discard_on ActiveJob::DeserializationError
     include Papyrus::Concerns::Consolidation
  end
end
