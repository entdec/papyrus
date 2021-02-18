module Papyrus
  class GenerateJob < ApplicationJob
    def perform(object, event, options, context)
      Papyrus::Generator.create(object, event, options, context).generate
    end
  end
end
