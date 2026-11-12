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

    test 'open returns nil for an attachment without a file' do
      context = Context.new(Papyrus::Template.create(description: 'some'))
      attached_one = ActiveStorage::Attached::One.new('logo', Papyrus::Template.new)
      attached_one.define_singleton_method(:attached?) { false }

      assert_nil context.open(attached_one)
      assert_nil context.open(ActiveStorageAttachedOneDrop.new(attached_one))
    end
  end
end
