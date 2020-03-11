# frozen_string_literal: true

module Papyrus
  module PrawnExtensions
    def barcode(symbology, data, options = {})
      klass = "Barby::#{symbology.classify}".safe_constantize
      return unless klass

      barcode = klass.new(data)
      outputter = Barby::PrawnOutputter.new(barcode)
      outputter.annotate_pdf(self, options)
    end
  end
end

Prawn::Document.extensions << Papyrus::PrawnExtensions
