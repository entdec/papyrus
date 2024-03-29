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

    test 'does not renders a liquid template with non-matching condition when an item is allocated' do
      item = Item.create(name: 'Test', state: 'available', description: 'Smurrefluts')
      assert_performed_jobs 1, only: [Papyrus::GenerateJob] do
        item.allocate
      end
      assert_equal 0, item.papers.count
    end

    test 'renders a liquid template with matching condition when an item is allocated' do
      item = Item.create(name: 'Yes', state: 'available', description: 'Test')
      assert_performed_jobs 1, only: [Papyrus::GenerateJob] do
        item.allocate!
      end
      assert_equal 1, item.papers.count
      assert_equal 'invoice', item.papers.first.purpose
      assert_equal 'PDF Label with condition', item.papers.first.template.description
    end

    test 'generates default file name if template is not present' do
      template = papyrus_templates(:pdf)
      file_name = template.file_name({ 'item' => { 'name' => 'shipment' } })

      assert_equal file_name, 'invoice.pdf'
    end

    test 'generates file name from template if present' do
      template = papyrus_templates(:pdf_for_file_name)
      file_name = template.file_name({ 'item' => { 'name' => 'shipment' } })

      assert_equal file_name, 'test_doc_shipment.pdf'
    end

  end
end
