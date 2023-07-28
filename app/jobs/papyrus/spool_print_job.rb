module Papyrus
  class SpoolPrintJob < ApplicationJob
    def perform(print_job_id)
      print_job = Papyrus::PrintJob.find(print_job_id)
      print_job.spool!
    end
  end
end
