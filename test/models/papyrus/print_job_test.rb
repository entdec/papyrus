require 'test_helper'

module Papyrus
  class PrintJobTest < ApplicationTestCase
    setup do
      @user = User.create(name: 'Test')
      @printer1 = @user.printers.create(name: 'Test printer')
      @user.preferred_printers.create(printer: @printer1, use: 'document')
    end
    test 'generates a printjob' do
      template = papyrus_templates(:pdf)
      paper, = template.generate(nil, { item: { name: 'Joe' } }, owner: @user)
      subject = paper.print!
      assert_equal @printer1, subject.printer
      assert_equal paper, subject.paper
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
