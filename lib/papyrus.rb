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
require 'papyrus/object_converter'

module Papyrus
  class Error < StandardError; end

  class UpdatePrintNodeInformationException < StandardError; end

  class Net::HTTPResponseError < StandardError; end

  class << self
    attr_reader :config
    delegate :logger, to: :@config

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

      model = Papyrus::ObjectConverter.serialize(obj)
      formatted_hash = Papyrus::ObjectConverter.serialize(@params)

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

      params = (Papyrus.config.default_params(event, obj) || {}).merge(params)

      options = params[:options] || {}
      if consolidate?
        params[:consolidation_id] = consolidation_id
        params[:group_id] = consolidation_group_id
      end
      model = Papyrus::ObjectConverter.serialize(obj)
      formatted_hash = Papyrus::ObjectConverter.serialize(params)

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

    # Print all papers generated for the given consolidation id.
    # Optionally the option group_id can be passed to  to only print papers generated under a specific group.
    # @param [String] consolidation_id
    # @param [Hash] options the options hash
    def print_consolidation(consolidation_id, options = {})
      Papyrus::ConsolidationSpoolJob.perform_async(consolidation_id, options)
    end

    def papers?(obj, event)
      Papyrus::Template.where(klass: Papyrus::BaseGenerator.class_names_for(obj),
                              event: Papyrus::BaseGenerator.event_name_for(
                                obj, event
                              )).where(enabled: true).count.positive?
    end

    # @return [Boolean] true if the current thread is in consolidation mode.
    def consolidate?
      return false unless papyrus_datastore.respond_to?(:key?)

      papyrus_datastore[:consolidation_id].present?
    end

    # @return [String] the consolidation id for the current thread.
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

    # Removes the datastore for the current thread.
    # (Also available via Thread.current[:papyrus_datastore])
    def remove_datastore
      Thread.current[:papyrus_datastore] = nil
    end

    # Start consolidating papers (print jobs) for the current thread inside the given block.
    # Set the consolidation_id for the current thread in the papyrus datastore so that
    # all papers generated inside the block will be generated with the same consolidation_id.
    def consolidate(&block)
      if Papyrus.consolidation_id.blank?
        consolidation_id = Papyrus.generate_consolidation_id
        add_thread_variables(consolidation_id: consolidation_id)
      end
      block.call
    ensure
      remove_datastore
    end

    # Creates a new group within the current consolidation process, assigning it a unique `group_id`.
    # This ensures that the papers in each group are handled separately and printed in the order they are processed.
    #
    # Use this method to group multiple print tasks together in one consolidation session, while keeping them organized by purpose.
    def consolidation_group(purposes = [], &block)
      return unless consolidate? && block

      group_id = uuid7
      add_thread_variables(group_id: group_id, purposes: purposes)
      block.call
    ensure
      remove_thread_variables(:group_id, :purposes)
    end

    def consolidation_group_id
      papyrus_datastore[:group_id] if consolidate?
    end

    def generate_consolidation_id(validate = true)
      consolidation_id = SecureRandom.uuid
      if validate
        10.times do
          break unless Papyrus::Paper.exists?(consolidation_id: consolidation_id)

          consolidation_id = SecureRandom.uuid
        end
      end
      consolidation_id
    end

    def uuid7
      current_time_ms = (Time.now.to_f * 1000).to_i

      if current_time_ms == @last_timestamp
        @last_random_bits += 1
      else
        @last_random_bits = SecureRandom.random_number(2 ** 74)
      end

      @last_timestamp = current_time_ms

      "%08x-%04x-7%03x-%04x-%012x" % [
        (current_time_ms & 0xFFFFFFFF), # 32 bits (8 hex digits) time low
        ((current_time_ms >> 32) & 0xFFFF), # 16 bits (4 hex digits) time mid
        (@last_random_bits >> 61) & 0xFFF, # 12 bits (3 hex digits, with version 7 prefix)
        (@last_random_bits >> 47) & 0xFFFF, # 16 bits (4 hex digits)
        @last_random_bits & 0xFFFFFFFFFFFF # 48 bits (12 hex digits)
      ]
    end

  end

  # Include helpers
  ActiveSupport.on_load(:active_record) do
    include Papyrus::ActiveRecordHelpers
  end
end
