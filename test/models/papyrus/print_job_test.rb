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
      paper, = template.generate({ name: 'Joe' }, owner: @user)
      subject = paper.print!
      assert_equal @printer1, subject.printer
      assert_equal paper, subject.paper
    end
  end
end
