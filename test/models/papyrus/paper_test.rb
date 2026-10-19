require 'test_helper'

module Papyrus
  class PaperTest < ActiveSupport::TestCase
    test 'automatically prints a new paper when enabled' do
      enqueued_print_jobs = []

      Papyrus.config.stub :allow_auto_print, true do
        Rails.stub :env, ActiveSupport::StringInquirer.new('production') do
          Papyrus::SpoolPrintJob.stub :perform_async, ->(id) { enqueued_print_jobs << id } do
            assert_difference 'Papyrus::PrintJob.count', 1 do
              Papyrus::Paper.create!(owner: users(:one), use: 'document', consolidation_id: nil)
            end
          end
        end
      end

      print_job = Papyrus::PrintJob.last
      assert_equal [print_job.id], enqueued_print_jobs
      assert_equal users(:one), print_job.paper.owner
    end
  end
end
