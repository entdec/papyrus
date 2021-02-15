require 'test_helper'

module Papyrus
  class TemplateTest < ActiveSupport::TestCase
    test 'renders a PDF' do
      subject = papyrus_templates(:pdf)
      result = subject.render({}).read

      text = PDF::Inspector::Text.analyze(result)

      assert_equal text.strings[0], 'Commercial Invoice'
    end
  end
end
