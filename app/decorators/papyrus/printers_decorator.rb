# frozen_string_literal: true

module Papyrus
  class PrintersDecorator < ApplicationDecorator
    def options_for_select
      model.map { |p| [p.name, p.id, { "data-chain": p.computer.id }] }
    end
  end
end
