module Papyrus

class ConsolidationCallback
  def initialize(handlers = {}, connection: ActiveRecord::Base.connection)
    @connection = connection
    @handlers = handlers
  end

  # rubocop: disable Naming/PredicateName
  def has_transactional_callbacks?
    true
  end
  # rubocop: enable Naming/PredicateName

  def before_committed!(*)
    @handlers[:before_commit]&.call
  end

  def trigger_transactional_callbacks?
    true
  end

  def committed!(*)
    @handlers[:after_commit]&.call
  end

  def rolledback!(*)
    @handlers[:after_rollback]&.call
  end

  # Required for +transaction(requires_new: true)+
  def add_to_transaction(*)
        @connection.add_transaction_record(self)
  end
end

end
