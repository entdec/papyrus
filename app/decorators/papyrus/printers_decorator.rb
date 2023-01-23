# frozen_string_literal: true

module Papyrus
  class PrintersDecorator < ApplicationDecorator
    def options_for_select
      model.map do |p|
        name = p.description.present? && p.name.downcase != p.description.downcase ? "#{p.name} - #{p.description}" : p.name
        [name, p.id, { "data-chain": p.computer.id }]
      end
    end
  end
end
