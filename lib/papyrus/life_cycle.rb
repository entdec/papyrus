# frozen_string_literal: true

module Papyrus
  module LifeCycle
    extend ActiveSupport::Concern

    included do
      raise "#{name} must be papyrable" unless papyrable?

      after_create { Papyrus::EventRecord.create(:create, self, data_store: Papyrus.papyrus_datastore.deep_dup) }
      after_update { Papyrus::EventRecord.create(:update, self, data_store: Papyrus.papyrus_datastore.deep_dup) }
      after_destroy { Papyrus::EventRecord.create(:destroy, self, data_store: Papyrus.papyrus_datastore.deep_dup) }
      after_save { Papyrus::EventRecord.create(:save, self, data_store: Papyrus.papyrus_datastore.deep_dup) }

      %i[create destroy update save].each do |event_name|
        next if generator.method_defined?(event_name)
        generator.send(:define_method, event_name) { |object, options = {}| }
      end
    end
  end
end
