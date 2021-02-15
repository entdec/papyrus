# frozen_string_literal: true

module Papyrus
  class TemplateDecorator < ApplicationDecorator
    def all_events
      events = []
      Papyrus.config.papyrable_class_names.each do |class_name|
        next if class_name == 'Custom'

        generator = Papyrus::Generator.generator_for_class(class_name)
        generator.instance_methods(false).each do |m|
          events << [m, m, { 'data-chain': class_name }]
        end
      end
      events.sort_by(&:first)
    end
  end
end
