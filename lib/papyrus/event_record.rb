require 'set'
require 'concurrent'

module Papyrus
  class EventRecord
    def initialize(event, record, params = {})
      @event = event
      @record = record
      @data_store = params[:data_store] || {}
      @state_machine = params[:state_machine] || false
      @connection = ActiveRecord::Base.connection
      @transaction_id = nil
      @bid = nil
    end

    def has_transactional_callbacks?
      true
    end

    def trigger_transactional_callbacks?
      true
    end

    def before_committed!(*) end

    def committed!(*)
      Papyrus.event(@event, @record, {options: {perform_now: true}}.merge(@data_store))
      Sidekiq::Batch::Server.new.call(@event_job, @event_job.payload, "default") { true }
    end

    def rolledback!(*)
      Sidekiq::Batch::Server.new.call(@event_job, @event_job.payload, "default") { true }
    end

    def add_to_transaction(*)
      current_transaction = @connection.current_transaction

      if current_transaction&.open?
        current_transaction.add_record(self)

        @transaction_id = current_transaction.object_id
        @bid = Thread.current[:sidekiq_batch]&.bid
        @event_job = EventJob.new
        Sidekiq::Batch::Client.new.call(@event_job.class.name, @event_job.payload, "default", Sidekiq.redis_pool) { true }
      else
        Papyrus.event(@event, @record, {options: {perform_now: true}}.merge(@data_store))
      end
    end

    def self.create(event, record, params = {})
      event_record = new(event, record, params)
      event_record.add_to_transaction
      event_record
    end

    private

    def transaction_storage
      Thread.current[:___papyrus_events] ||= Concurrent::Map.new
      Thread.current[:___papyrus_events][:transactions] ||= Concurrent::Map.new
    end

    def initialize_transaction_state(transaction_id)
      transactions = transaction_storage
      unless transactions[transaction_id]
        transactions[transaction_id] = {events: Set.new}
      end
      transactions[transaction_id][:events] << {event: @event, record_id: @record.id}
    end

    def clear_transaction_state(transaction_id)
      transactions = transaction_storage
      transactions.delete(transaction_id)

      Thread.current[:___papyrus_events].delete(:transactions) if transactions.empty?
    end

    def sidekiq_batch
      Sidekiq::Batch.new(@bid) if @bid
    rescue StandardError
      nil
    end

  end

  class EventJob
    include Sidekiq::Job
    include Sidekiq::JobUtil

    def perform; end

    def payload
      raw = {}.merge("args" => [], "class" => self.class.name)
      result = normalize_item(raw)
      result["retry"] = false
      result
    end

  end
end
