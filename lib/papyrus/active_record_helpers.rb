# frozen_string_literal: true

module Papyrus
  module ActiveRecordHelpers
    extend ActiveSupport::Concern

    class_methods do
      def printing
        has_many :printers, class_name: 'Papryus::Printer'
        has_many :print_jobs, class_name: 'Papryus::PrintJob', through: :printers
      end

      def papyrable(options = {})
        has_many :papers, as: :papyrable, class_name: 'Papyrus::Paper'
        Papyrus::InitializeForClassService.perform!(self, options)
        class_variable_set(:@@_is_papyrable, true)
      end

      def papyrable?
        return false unless class_variable_defined?(:@@_is_papyrable)

        class_variable_get(:@@_is_papyrable)
      end
    end

    included do
      delegate :papyrable?, to: :class
    end
  end
end
