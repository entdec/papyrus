# frozen_string_literal: true

require 'auxilium'
require 'img2zpl'
require 'labelary'
require 'liquidum'
require 'printnode'
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
require 'papyrus/deprecator'
require 'papyrus/engine'
require 'papyrus/i18n_store'
require 'papyrus/prawn_extensions'
require 'papyrus/shash'
require 'papyrus/print_node_utils'

module Papyrus
  class Error < StandardError; end

  @@consolidation_id = nil

  class << self
    attr_reader :config

    def setup
      @config = Configuration.new
      yield config
    end

    def i18n_store
      @i18n_store ||= Papyrus::I18nStore.new
    end

    def refresh!
      Papyrus::UpdatePrintNodeInformationJob.perform_later
    end

    def print_client
      return if Papyrus.config.print_client_api_key.blank?

      @auth ||= PrintNode::Auth.new(Papyrus.config.print_client_api_key)
      @print_client ||= PrintNode::Client.new(@auth)
    end

    def generate(event)
      return unless event

      Papyrus::GenerateJob.perform_later(@obj, event.to_s, @params)
    end
    deprecate generate: 'please use event instead', deprecator: Papyrus::Deprecator.new

    def with(obj, params = {})
      @obj = obj
      @params = params

      self
    end
    deprecate with: 'please use event instead', deprecator: Papyrus::Deprecator.new

    def event(event, obj, params = {})
      puts "EVENT: #{event} - #{Process.ppid} / #{Process.pid}"
      return unless event
      return unless obj.papyrable?
      return unless papers?(obj, event)

      options = params[:options] || {}

      if @@consolidation_id.present?
        params[:consolidation_id] = @@consolidation_id
      end

      if options[:perform_now] == true
        Papyrus::GenerateJob.perform_now(obj, event.to_s, params)
      else
        job = Papyrus::GenerateJob
        job.set(wait: options[:wait]) if options[:wait]
        job.perform_later(obj, event.to_s, params)
      end
    end

    def metadata_definition(field)
      config.metadata_fields[field]
    end

    def metadata_definitions
      config.metadata_fields
    end

    def start_consolidation(consolidation_id)
      end_current_consolidation

      consolidation_id = consolidation_id&.to_s || SecureRandom.uuid

      if consolidation_id.blank?
        consolidation_id = nil
        Praesens.store.delete :papyrus_consolidation_id
      else
        Praesens.store[:papyrus_consolidation_id] = consolidation_id
      end
      puts "CONSOLIDATE: #{consolidation_id} - #{Process.ppid} / #{Process.pid}"

      @@consolidation_id = consolidation_id
    end

    def end_consolidation
      return if @@consolidation_id.nil?

      end_current_consolidation if Praesens.store[:papyrus_consolidation_id] == @@consolidation_id

      Praesens.store.delete :papyrus_consolidation_id
    end


    def consolidate(consolidation_id = nil, &block)
      return if block.nil?

      Papyrus::ConsolidationJob.perform_later(consolidation_id, block)
    end

    def papers?(obj, event)
      Papyrus::Template.where(klass: Papyrus::BaseGenerator.class_names_for(obj),
                              event: Papyrus::BaseGenerator.event_name_for(
                                obj, event
                              )).where(enabled: true).count.positive?
    end

    private

    def end_current_consolidation
      return if @@consolidation_id.nil?

      consolidation_id = @@consolidation_id
      @@consolidation_id = nil
      Papyrus::ConsolidationSpoolJob.perform_later(consolidation_id)
    end

  end

  # Include helpers
  ActiveSupport.on_load(:active_record) do
    include Papyrus::ActiveRecordHelpers
  end
end
