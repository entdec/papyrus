# frozen_string_literal: true

module Papyrus
  module LifeCycle
    extend ActiveSupport::Concern

    included do
      raise "#{name} must be papyrable" unless papyrable?

      after_commit do
        if previously_persisted?
          Papyrus.event(:destroy, self, Papyrus.config.default_params(:destroy, self))
        else
          event = previously_new_record? ? :create : :update
          Papyrus.event(event, self, Papyrus.config.default_params(event, self))
          Papyrus.event(:save, self, Papyrus.config.default_params(:save, self))
        end
      end

      %i[create destroy update save].each do |event_name|
        next if generator.method_defined?(event_name)
        generator.send(:define_method, event_name) { |object, options = {}| }
      end
    end

  end
end
