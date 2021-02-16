require 'test_helper'

module Papyrus
  class TemplateTest < ActiveSupport::TestCase
    test 'renders a PDF' do
      subject = papyrus_templates(:pdf)
      result = subject.render({ name: 'Joe' }).read

      text = PDF::Inspector::Text.analyze(result)

      assert_equal text.strings[0], 'Commercial Invoice'
      assert_equal text.strings[1], 'Joe'
    end
  end
end
