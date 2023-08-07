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
require 'papyrus/consolidation_callback'
require 'papyrus/consolidation'
require 'papyrus/format_params'

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

    def refresh!
      Papyrus::UpdatePrintNodeInformationJob.perform_async
    end

    def print_client
      return if Papyrus.config.print_client_api_key.blank?

      @auth ||= PrintNode::Auth.new(Papyrus.config.print_client_api_key)
      @print_client ||= PrintNode::Client.new(@auth)
    end

    def generate(event)
      return unless event

      model = Papyrus::FormatParams.new(obj).serialize
      formatted_hash = Papyrus::FormatParams.new(@params).serialize

      Papyrus::GenerateJob.perform_async(event.to_s, model, formatted_hash)
    end

    deprecate generate: 'please use event instead', deprecator: Papyrus::Deprecator.new

    def with(obj, params = {})
      @obj = obj
      @params = params

      self
    end

    deprecate with: 'please use event instead', deprecator: Papyrus::Deprecator.new

    def event(event, obj, params = {})
      return unless event
      return unless obj.papyrable?
      return unless papers?(obj, event)

      options = params[:options] || {}
      params[:consolidation_id] = consolidation_id if consolidate?
      model = Papyrus::FormatParams.new(obj).serialize
      formatted_hash = Papyrus::FormatParams.new(params).serialize

      if options[:perform_now] == true || consolidate?
        Papyrus::GenerateJob.perform_sync(event.to_s, model, formatted_hash)
      else
        job = Papyrus::GenerateJob
        job.set(wait: options[:wait]) if options[:wait]
        job.perform_async(event.to_s, model, formatted_hash)
      end
    end

    def metadata_definition(field)
      config.metadata_fields[field]
    end

    def metadata_definitions
      config.metadata_fields
    end

    #
    # Start consolidation of papers that are created using the Papyrus.event method.
    # This will ensure that all papers created within the block will be consolidated
    # into a single print job.
    #
    # Example:
    #   Papyrus.start_consolidation do |consolidation_id|
    #    # Create print jobs here
    #   end
    #
    # @param [Hash] options
    # @option options [String] :consolidation_id
    #   The consolidation id to use. If the consolidation id is blank, a random UUID will be used.
    #
    # @return The result of the block.
    #
    def start_consolidation(options = {}, &block)
      return unless block

      consolidation_id = options[:consolidation_id]
      consolidation_id = SecureRandom.uuid if consolidation_id.blank?

      Papyrus.add_thread_variables(consolidation_id: consolidation_id)

      result = nil
      ActiveRecord::Base.transaction(requires_new: true) do
        begin
          result = (block.arity == 1 ? block.call(consolidation_id) : block.call)

          handlers = {
            after_commit: proc do
              consolidation_id = Papyrus.consolidation_id
              Papyrus.remove_thread_variables(:consolidation_id)
              print_consolidation(consolidation_id)
            end
          }
          ActiveRecord::Base.connection.add_transaction_record(Papyrus::ConsolidationCallback.new(handlers))
        rescue StandardError => e
          Papyrus.remove_thread_variables(:consolidation_id)
          raise e
        end
      end

      result
    end

    def print_consolidation(consolidation_id)
      Papyrus::ConsolidationSpoolJob.perform_async(consolidation_id)
    end

    def papers?(obj, event)
      Papyrus::Template.where(klass: Papyrus::BaseGenerator.class_names_for(obj),
                              event: Papyrus::BaseGenerator.event_name_for(
                                obj, event
                              )).where(enabled: true).count.positive?
    end

    # Returns true if consolidation is currently active for the current thread.
    def consolidate?
      return false unless papyrus_datastore.respond_to?(:key?)

      papyrus_datastore[:consolidation_id].present?
    end

    # Returns the linked consolidation id for the current thread.
    def consolidation_id
      papyrus_datastore[:consolidation_id] if consolidate?
    end

    def papyrus_datastore
      Thread.current[:papyrus_datastore] ||= HashWithIndifferentAccess.new
    end

    # Removes thread variables for the current thread.
    # (Also available via Thread.current[:papyrus_variables])
    # @param [Array] keys
    #  The keys to remove.
    def remove_thread_variables(*keys)
      variables = papyrus_datastore
      return unless variables&.respond_to?(:key?)

      keys.each { |key| variables.delete(key) }
    end

    # Adds or updates the thread variables for the current thread.
    # (Also available via Thread.current[:papyrus_variables])
    # @param [Hash] variables
    def add_thread_variables(**variables)
      papyrus_datastore.merge!(variables)
    end
  end

  # Include helpers
  ActiveSupport.on_load(:active_record) do
    include Papyrus::ActiveRecordHelpers
  end
end
