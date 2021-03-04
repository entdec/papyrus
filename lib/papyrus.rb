# frozen_string_literal: true

require 'img2zpl'
require 'prawn'
require 'prawn-svg'
require 'prawn/table'
require 'prawn/measurement_extensions'
require 'servitium'
require 'state_machines-activemodel'
require 'tilt'
require 'transactio'

require 'barby'
require 'barby/barcode/bookland'
require 'barby/barcode/codabar'
require 'barby/barcode/code_25'
require 'barby/barcode/code_25_iata'
require 'barby/barcode/code_25_interleaved'
require 'barby/barcode/code_39'
require 'barby/barcode/code_93'
require 'barby/barcode/code_128'
require 'barby/barcode/ean_8'
require 'barby/barcode/ean_13'
require 'barby/barcode/gs1_128'
require 'barby/barcode/qr_code'
require 'barby/barcode/upc_supplemental'
require 'barby/outputter/prawn_outputter'

require 'papyrus/active_record_helpers'
require 'papyrus/attachments_helpers'
require 'papyrus/attachment_helpers'
require 'papyrus/configuration'
require 'papyrus/context'
require 'papyrus/engine'
require 'papyrus/i18n_store'
require 'papyrus/prawn_extensions'
require 'papyrus/shash'

module Papyrus
  class Error < StandardError; end

  class << self
    attr_reader :config

    def setup
      @config = Configuration.new
      yield config
    end

    def i18n_store
      @i18n_store ||= Papyrus::I18nStore.new
    end

    def generate(event)
      return unless event

      Papyrus::GenerateJob.perform_later(@obj, event.to_s, @params)
    end

    def with(obj, params = {})
      @obj = obj
      @params = params.merge(Papyrus.config.default_params)

      self
    end

    def metadata_definition(field)
      config.metadata_fields[field]
    end

    def metadata_definitions
      config.metadata_fields
    end
  end

  # Include helpers
  ActiveSupport.on_load(:active_record) do
    include Papyrus::ActiveRecordHelpers
  end
end
