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
      return unless event
      return unless obj.papyrable?
      return unless papers?(obj, event)

      options = params[:options] || {}

      if consolidation_id.present?
        params[:consolidation_id] = consolidation_id
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

    #
    # Start consolidation of papers that are created using the Papyrus.event method.
    # This will ensure that all papers created within the block or
    # until the end_consolidation method is called will be consolidated
    # into a single print job.
    #
    # Example:
    #   Papyrus.start_consolidation do |consolidation_id|
    #    # Create print jobs here
    #   end
    #
    #  Papyrus.start_consolidation(consolidation_id: 'my_consolidation_id')
    #  # Create print jobs here
    #  Papyrus.end_consolidation
    #
    # @param [Hash] options
    # @option options [String] :consolidation_id
    #   The consolidation id to use. If the consolidation id is blank, a random UUID will be used.
    # @option options [Boolean] :force
    #  If set the true, the current consolidation will be ended and a new one started
    #  using the provided consolidation_id.
    #
    # @return [Object] The result of the block if a block is given.
    #  return the consolidation_id if no block is given.
    def start_consolidation(options = {}, &block)
      if consolidate?
        if options[:force] == true
          end_consolidation
        else
          return
        end
      end

      consolidation_id = options[:consolidation_id]
      consolidation_id = SecureRandom.uuid if consolidation_id.blank?

      Papyrus.add_thread_variables(
        consolidation_id: consolidation_id,
        consolidation_root_thread: true
      )

      result = nil
      if block
        ActiveRecord::Base.transaction(requires_new: true) do
          result = (block.arity == 1 ? block.call(consolidation_id) : block.call)
          end_consolidation
        end
      else
        result = consolidation_id
      end
      result
    end

    # Ends consolidation and schedules a spool job by default to send the
    # consolidated papers to PrintNode.
    #
    # This will only execute if the current thread started the consolidation.
    #
    # @param [Boolean] spool Defaults to true. If set to false, the spool job will not be scheduled.
    def end_consolidation(spool: true)
      if Papyrus.consolidation_root_thread?
        handlers = {
          after_commit: proc do
            consolidation_id = Papyrus.consolidation_id
            Papyrus.remove_thread_variables(:consolidation_id, :consolidation_root_thread)
            Papyrus::ConsolidationSpoolJob.perform_later(consolidation_id) if spool
          end
        }
        ActiveRecord::Base.connection.add_transaction_record(Papyrus::ConsolidationCallback.new(handlers))
      end
    end

    def papers?(obj, event)
      Papyrus::Template.where(klass: Papyrus::BaseGenerator.class_names_for(obj),
                              event: Papyrus::BaseGenerator.event_name_for(
                                obj, event
                              )).where(enabled: true).count.positive?
    end

    # Returns true if consolidation is currently active for the current thread.
    def consolidate?
      Thread.current[:papyrus_variables].respond_to?(:key?) &&
        Thread.current[:papyrus_variables][:consolidation_id].present?
    end

    # Returns the linked consolidation id for the current thread.
    def consolidation_id
      Thread.current[:papyrus_variables][:consolidation_id] if consolidate?
    end

    # Returns true if the current thread is the thread that started the consolidation.
    # Only the thread that started the consolidation can end consolidation.
    def consolidation_root_thread?
      return Thread.current[:papyrus_variables].respond_to?(:key?) &&
        Thread.current[:papyrus_variables][:consolidation_root_thread] == true
    end

    # Removes thread variables for the current thread.
    # (Also available via Thread.current[:papyrus_variables])
    # @param [Array] keys
    #  The keys to remove.
    def remove_thread_variables(*keys)
      variables = Thread.current[:papyrus_variables]
      return if !variables.respond_to?(:key?)

      keys.each { |key| variables.delete(key) }
    end

    # Adds or updates the thread variables for the current thread.
    # (Also available via Thread.current[:papyrus_variables])
    # @param [Hash] variables
    def add_thread_variables(**variables)
      Thread.current[:papyrus_variables] ||= {}
      Thread.current[:papyrus_variables].merge!(variables)
    end
  end

  # Include helpers
  ActiveSupport.on_load(:active_record) do
    include Papyrus::ActiveRecordHelpers
  end
end
