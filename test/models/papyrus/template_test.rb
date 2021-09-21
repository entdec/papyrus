require 'test_helper'

module Papyrus
  class TemplateTest < ApplicationTestCase
    test 'renders a PDF' do
      subject = papyrus_templates(:pdf)
      result = subject.render({ 'item' => { 'name' => 'Joe' } }).read

      text = PDF::Inspector::Text.analyze(result)

      assert_equal text.strings[0], 'Commercial Invoice'
      assert_equal text.strings[1], 'Joe'
    end

    test 'renders a liquid template' do
      subject = papyrus_templates(:zpl)
      result = subject.render({ 'item' => { 'name' => 'Joe' } }).read

      assert_includes result, 'Part number # Joe'
    end

    test 'renders a pdf when an item is saved' do
      item = Item.first # Needed to have papyrable class names set
      assert_performed_jobs 1, only: [Papyrus::GenerateJob] do
        item = Item.create!(name: 'Test', description: 'Smurrefluts')
      end
      assert_equal 1, item.papers.count
      assert_equal 'invoice', item.papers.first.purpose
    end

    test 'renders a liquid template when an item is saved' do
      item = items(:one)
      assert_performed_jobs 1, only: [Papyrus::GenerateJob] do
        item.update!(name: 'Test', description: 'Smurrefluts')
      end
      assert_equal 1, item.papers.count
      assert_equal 'inventory_label', item.papers.first.purpose
    end
  end
end
