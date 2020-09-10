require 'test_helper'

module Papyrus
  class ContextTest < ActiveSupport::TestCase
    test 'Translations' do
      Papyrus::Locale.create(key: 'en', data: { en: { some: 'Somesome' } })
      template = Papyrus::Template.create(description: 'some')
      context = Context.new(template)
      I18n.with_locale(:en) do
        assert_equal 'Somesome', context.translate('some')
      end
    end
  end
end
