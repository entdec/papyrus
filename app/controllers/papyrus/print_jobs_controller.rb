# frozen_string_literal: true

require_dependency 'papyrus/application_controller'

module Papyrus
  class PrintJobsController < ApplicationController
    protect_from_forgery with: :exception
    before_action :set_objects

    def resend
      @print_job.update_column(:state, 'pending')
      @print_job.spool!
    end

    private

    def set_objects
      @print_job = PrintJob.find(params[:id])
    end
  end
end
