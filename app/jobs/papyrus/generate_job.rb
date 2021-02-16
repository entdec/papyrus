module Papyrus
  class GenerateJob < ApplicationJob
    def perform(object, event, context)
      Papyrus::Generator.create(object, event, context).call
    end
  end
end
