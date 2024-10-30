# frozen_string_literal: true

module Papyrus
  module LifeCycle
    extend ActiveSupport::Concern

    included do
      raise "#{name} must be papyrable" unless papyrable?

      after_create_commit do
        Papyrus.event(:create, self)
      end

      after_update_commit do
        Papyrus.event(:update, self)
      end

      after_save_commit do
        Papyrus.event(:save, self)
      end

      after_destroy_commit do
        Papyrus.event(:destroy, self)
      end

      %i[create destroy update save].each do |event_name|
        next if generator.method_defined?(event_name)
        generator.send(:define_method, event_name) { |object, options = {}| }
      end
    end
  end
end
