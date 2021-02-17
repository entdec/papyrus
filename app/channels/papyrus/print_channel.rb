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
      Papyrus::UpdatePrintersJob.perform_later(current_user, data)
    end

    def printed(data); end
  end
end
