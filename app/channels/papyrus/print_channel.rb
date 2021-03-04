# frozen_string_literal: true

require_dependency 'papyrus/application_cable/channel'

module Papyrus
  class PrintChannel < ApplicationCable::Channel
    def subscribed
      stream_for current_user
    end

    def unsubscribed
      # Any cleanup needed when channel is unsubscribed
    end

    def printers_list(data)
      # FIXME: Only do this once every 5min?
      Papyrus::UpdatePrintersJob.perform_later(current_user, data)
    end

    def printing(data)
      print_job = Papyrus::PrintJob.find_by_id(data['print_job_id'])

      return unless print_job

      print_job.started!
    end

    def errored(data)
      print_job = Papyrus::PrintJob.find_by_id(data['print_job_id'])

      return unless print_job

      print_job.errored!
    end

    def printed(data)
      print_job = Papyrus::PrintJob.find_by_id(data['print_job_id'])

      return unless print_job

      print_job.finished!
    end
  end
end
