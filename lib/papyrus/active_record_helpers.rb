# frozen_string_literal: true

require_relative 'papyrable'
require_relative 'state_machine'
require_relative 'transactio'

module Papyrus
  module ActiveRecordHelpers
    extend ActiveSupport::Concern

    included do
      delegate :papyrable?, to: :class

      def printers?
        printers.count.positive?
      end
    end

    class_methods do
      def printing
        has_many :printers, class_name: 'Papyrus::Printer', as: :owner

        has_many :preferred_printers, class_name: 'Papyrus::PreferredPrinter', as: :owner
        accepts_nested_attributes_for :preferred_printers, reject_if: :blank?, allow_destroy: true

        has_many :print_jobs, class_name: 'Papyrus::PrintJob', through: :printers
      end

      def papyrable(options = {})
        @_papyrus_papyrable_options = options
        include Papyrus::Papyrable
        include Papyrus::StateMachine if options[:state_machine]
        include Papyrus::Transactio
      end

      def papyrable?
        included_modules.include?(Papyrus::Papyrable)
      end
    end
  end
end
