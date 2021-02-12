# frozen_string_literal: true

module Papyrus
  module ActiveRecordHelpers
    extend ActiveSupport::Concern

    class_methods do
      def printing
        has_many :printers, class_name: 'Papryus::Printer'
        has_many :print_jobs, class_name: 'Papryus::PrintJob', through: :printers

        send :include, Papyrus::ActiveRecordHelpers::InstanceMethods
        extend(Papyrus::ActiveRecordHelpers::ClassMethods)
      end
    end

    module ClassMethods
    end

    module InstanceMethods
    end
  end
end
