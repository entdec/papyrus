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
      # binding.pry
      Papyrus::UpdatePrintersJob.perform_later(user, data)
      # signal = Papyrus::Signal.find_by_id(data['signal_id'])

      # return unless signal

      # signal.show!
    end

    def close(data)
      # signal = Papyrus::Signal.find_by_id(data['signal_id'])

      # return unless signal

      # signal.close!
    end
  end
end
