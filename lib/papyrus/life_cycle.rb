# frozen_string_literal: true

module Papyrus
  module LifeCycle
    extend ActiveSupport::Concern

    included do
      raise "#{name} must be papyrable" unless papyrable?

      after_commit do
        if previously_persisted?
          Papyrus.event(:destroy, self)
        elsif previously_new_record?
          Papyrus.event(:create, self)
          Papyrus.event(:save, self)
        else
          Papyrus.event(:update, self)
          Papyrus.event(:save, self)
        end
      end

      %i[create destroy update save].each do |event_name|
        next if generator.method_defined?(event_name)
        generator.send(:define_method, event_name) { |object, options = {}| }
      end
    end
  end
end
