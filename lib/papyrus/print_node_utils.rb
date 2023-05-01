# frozen_string_literal: true
module Papyrus
  class PrintNodeUtils


    class << self

      RATE_LIMIT_RETRY_INTERVAL = 2.seconds
      RATE_LIMIT_RETRY_AMOUNT = 10

      def retry_on_rate_limit
        response = yield


        retried = 0
        while retried < RATE_LIMIT_RETRY_AMOUNT && rate_limit_exceeded?(response)
          sleep RATE_LIMIT_RETRY_INTERVAL
          response = yield
          retried += 1
        end

        response
      end


      def rate_limit_exceeded?(response)
        return false unless response.respond_to?(:key?)
        response['code'].eql? 'TooManyRequests'
      end

    end
  end
end
