require 'test_helper'

module Papyrus
  class TemplateTest < ApplicationTestCase
    test 'renders a PDF' do
      subject = papyrus_templates(:pdf)
      result = subject.render({ name: 'Joe' }).read

      text = PDF::Inspector::Text.analyze(result)

      assert_equal text.strings[0], 'Commercial Invoice'
      assert_equal text.strings[1], 'Joe'
    end

    test 'renders a pdf when an item is saved' do
      item = Item.first # Needed to have papyrable class names set
      assert_performed_jobs 2, only: [Papyrus::GenerateJob] do
        item = Item.create!(name: 'Test', description: 'Smurrefluts')
      end
      assert_equal 1, item.papers.count
    end
  end
end
