# frozen_string_literal: true

module Papyrus
  module PrawnExtensions
    def barcode(symbology, data, options = {}, barcode_options = {})
      Barby::QrCode
      klass = "Barby::#{symbology.classify}".safe_constantize
      return unless klass

      barcode = klass.new(data, barcode_options)
      outputter = Barby::PrawnOutputter.new(barcode)
      outputter.annotate_pdf(self, options)
    end
  end
end

Prawn::Document.extensions << Papyrus::PrawnExtensions
