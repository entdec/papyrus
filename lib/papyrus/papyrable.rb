# frozen_string_literal: true

module Papyrus
  module Papyrable
    extend ActiveSupport::Concern

    class_methods do
      def papyrable_options
        @_papyrus_papyrable_options || {}
      end

      def generator
        Papyrus::BaseGenerator.generator_for_class(name)
      end
    end

    included do
      raise "Papyrus Generator missing for class #{name}, please create a #{Papyrus::BaseGenerator.generator_name_for_class(name)}" unless generator

      Papyrus.config.add_papyrable_class(self)
      has_many :papers, as: :papyrable, class_name: 'Papyrus::Paper'
    end
  end
end
