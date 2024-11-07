module Papyrus

  # Include this module in your job (where Sidekiq::Job is included)
  # to log the `perform_inline` method call to avoid synchronous jobs from
  # being registered on the current open batch.
  module JobPerformLogger

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def included(mod)
        super

        mod.class_eval do
          if defined?(Sidekiq::Job) && mod.included_modules.include?(Sidekiq::Job) && !mod.included_modules.include?(Papyrus::JobPerformLogger)
            alias_method :perform_inline_without_logging, :perform_inline
            alias_method :perform_inline, :perform_inline_with_logging
          end
        end
      end
    end

    def perform_inline_with_logging(*args)
      Thread.current[:sidekiq_job_sync_execution] = true
      perform_inline_without_logging(*args)
    ensure
      Thread.current[:sidekiq_job_sync_execution] = false
    end
  end
end
