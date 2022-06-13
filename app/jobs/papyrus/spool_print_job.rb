module Papyrus
  class SpoolPrintJob < ApplicationJob
    def perform(print_job)
      print_job.spool!
    end
  end
end
