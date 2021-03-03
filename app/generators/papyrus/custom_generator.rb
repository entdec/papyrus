# frozen_string_literal: true

module Papyrus
  class CustomGenerator < BaseGenerator
    def respond_to_missing?(_symbol, _include_all)
      event != @event.to_sym
    end

    def method_missing(event, object = nil, params = {})
      super if event != @event.to_sym
    end
  end
end
