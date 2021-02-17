module Papyrus
  class GenerateJob < ApplicationJob
    def perform(object, event, options)
      Papyrus::Generator.create(object, event, options).call
    end
  end
end
