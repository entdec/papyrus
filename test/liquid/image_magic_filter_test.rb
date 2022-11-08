# frozen_string_literal: true

require 'test_helper'

class ImageMagicFilterTest < ActiveSupport::TestCase
  test 'will allow conversion to zpl' do
    template_data = %({{'meater-logo-vector.png'|image_magic: 'to_zpl'}})

    @template = Papyrus::Template.create(description: 'some', kind: 'liquid', data: template_data)
    @template.attachments.attach filename: 'meater-logo-vector.png',
                                 io: open('./test/fixtures/files/meater-logo-vector.png')

    result = Liquidum.render(@template.data, context: {}, registers: { 'template' => @template })

    assert_equal(
      '^GFA,8775,8775,75,!::gQFE!TF7!RFD!!PFE!gIFE!!gIFBLFBFFD!!::gKFD!!gQFE!gKF7!!:gJFE!!:::::IFD!!WF7lMFB!VFElNFE!FFE!!hKF7!FFBhTFEgQF7!jRFE!!TFE!gOFB!!TFB!QFDlVFD!hLFB!hVFDjNFD!hLFD!!:jPFB!PFD!!hUFD!hJFDFFDgYFBIFE!OFBhNFB!!RFE!!jLFEKFB!jOFBKF7!hKFD!hTFB!PFEgTFEFFEjWFB!QF7!jNFE!gFD!mKFE!OFE!gHFB!hLFEhGFB!hSF7FF7gNFD!PFDOFEgOF7hHFDhTFB!!QF7QFB!gGFBiKFE!jKF7!hMFEhLF7FE!gJFBgPF7!gJFDgIF7!gJFEgOFE!gHFDFF7gKFBjSFB!MFERFDJFBiQFB!gKFDkYFD!gKFE!gGFD!hOF7jVF7!PFDhHFE!!VFD!!DKF7VF7!!OFEJFDFFBgRF7gRFB!EgLFDiMFDhNF7FFB!!hRFD!UFB!jHFE!NFEjMF7FF7!!:mKFB!FEPFDiRFB!jVFDFFD!JFBQF7lRF7gPF7!MFD!jJFE!jWF7!jGFD!!kFB!gNFE!!gIFD!gJF7!!::^FS', result
    )
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
