# frozen_string_literal: true

require 'test_helper'

class ImageMagicFilterTest < ActiveSupport::TestCase
  test 'will allow conversion to zpl' do
    template_data = %({{'meater-logo-vector.png'|image_magic: 'to_zpl'}})

    @template = Papyrus::Template.create(description: 'some', kind: 'liquid', data: template_data)
    @template.attachments.attach filename: 'meater-logo-vector.png',
                                 io: open('./test/fixtures/files/meater-logo-vector.png')

    result = Liquidum.render(@template.data, context: {}, registers: { 'template' => @template })

    assert_match(/\A\^GFA,\d+,\d+,\d+,.+\^FS\z/m, result)
  end

  test 'will allow resize and conversion to zpl' do
    template_data = %({{'meater-logo-vector.png'|image_magic: 'background:white'|image_magic: 'flatten'|image_magic: 'monochrome'|image_magic: 'resize:300'|image_magic: 'to_zpl'}})

    @template = Papyrus::Template.create(description: 'some', kind: 'liquid', data: template_data)
    @template.attachments.attach filename: 'meater-logo-vector.png',
                                 io: open('./test/fixtures/files/meater-logo-vector.png')

    result = Liquidum.render(@template.data, context: {}, registers: { 'template' => @template })

    assert_includes result, '^GFA'
  end
end
