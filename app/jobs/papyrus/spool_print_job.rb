module Papyrus
  class SpoolPrintJob < ApplicationJob
    def perform(print_job_id)
      print_job = Papyrus::PrintJob.find_by(id: print_job_id)
      return if print_job.blank?
      print_job.spool!
    end
  end
end
