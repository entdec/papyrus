require 'test_helper'

module Papyrus
  class PrintJobTest < ApplicationTestCase
    setup do
      @user = User.create(name: 'Test')
      @printer1 = Papyrus::Printer.create!(name: 'Test printer', client_id: 1, computer: papyrus_computers(:one))
      @user.preferred_printers.create!(printer: @printer1, use: 'document', computer: papyrus_computers(:one))
    end
    test 'generates a printjob' do
      template = papyrus_templates(:pdf)
      paper, = template.generate(nil, { item: { name: 'Joe' } }, owner: @user)
      Rails.stub :env, ActiveSupport::StringInquirer.new('production') do
        subject = paper.print!
        assert_equal @printer1, subject.printer
        assert_equal paper, subject.paper
      end
    end

    test 'states' do
      template = papyrus_templates(:pdf)
      paper, = template.generate(nil, { item: { name: 'Joe' } }, owner: @user)

      subject = Papyrus::PrintJob.create(printer: @printer1, paper: paper)
      assert_equal 'pending', subject.state
      subject.started!
      assert_equal 'printing', subject.state
      subject.errored!
      assert_equal 'error', subject.state
      subject.finished!
      assert_equal 'printed', subject.state
    end
  end
end
