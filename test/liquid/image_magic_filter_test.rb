# frozen_string_literal: true

require 'test_helper'

class ImageMagicFilterTest < ActiveSupport::TestCase
  test 'will allow conversion to zpl' do
    template_data = %({{'meater-logo-vector.png'|image_magic: 'to_zpl'}})

    @template = Papyrus::Template.create(description: 'some', kind: 'liquid', data: template_data)
    @template.attachments.attach filename: 'meater-logo-vector.png',
                                 io: open('./test/fixtures/files/meater-logo-vector.png')

    result = Liquor.render(@template.data, context: {}, registers: { 'template' => @template })

    assert_equal(
      '^GFA,8775,8775,75,!::gQFE!TF7!RFD!!PFE!gIFE!!gIFBLFBFFD!!::gKFD!!gQFE!gKF7!!:gJFE!!:::::IFD!!WF7lMFB!VFElNFE!FFE!!hKF7!FFBhTFEgQF7!jRFE!!TFE!gOFB!!TFB!QFDlVFD!hLFB!hVFDjNFD!hLFD!!:jPFB!PFD!!hUFD!hJFDFFDgYFBIFE!OFBhNFB!!RFE!!jLFEKFB!jOFBKF7!hKFD!hTFB!PFEgTFEFFEjWFB!QF7!jNFE!gFD!mKFE!OFE!gHFB!hLFEhGFB!hSF7FF7gNFD!PFDOFEgOF7hHFDhTFB!!QF7QFB!gGFBiKFE!jKF7!hMFEhLF7FE!gJFBgPF7!gJFDgIF7!gJFEgOFE!gHFDFF7gKFBjSFB!MFERFDJFBiQFB!gKFDkYFD!gKFE!gGFD!hOF7jVF7!PFDhHFE!!VFD!!DKF7VF7!!OFEJFDFFBgRF7gRFB!EgLFDiMFDhNF7FFB!!hRFD!UFB!jHFE!NFEjMF7FF7!!:mKFB!FEPFDiRFB!jVFDFFD!JFBQF7lRF7gPF7!MFD!jJFE!jWF7!jGFD!!kFB!gNFE!!gIFD!gJF7!!::^FS', result
    )
  end

  test 'will allow resize and conversion to zpl' do
    template_data = %({{'meater-logo-vector.png'|image_magic: 'background:white'|image_magic: 'flatten'|image_magic: 'monochrome'|image_magic: 'resize:300'|image_magic: 'to_zpl'}})

    @template = Papyrus::Template.create(description: 'some', kind: 'liquid', data: template_data)
    @template.attachments.attach filename: 'meater-logo-vector.png',
                                 io: open('./test/fixtures/files/meater-logo-vector.png')

    result = Liquor.render(@template.data, context: {}, registers: { 'template' => @template })

    assert_equal(
      '^GFA,2242,2242,38,S07F8,S0FFE,M0FF8003IF,K01JF807IF8,K0LF0FE0FC,J03LFDF807E,J0OF001F,I01NFE001F,I07NFCI0F,I0OFCI0F8,001OF8I078,003OF8I078,007OF8I078,00LFEIFCI078,01LFDIFCI0F8I0AM01A002AAE99AK0AI06492492A80AE1A66802JA,03LF3IFCI0FI01F8L07E007KFEJ01FI0NF81LFC07JFE,03KFE7IFE001FI01FCL07E007KFEJ01F800NF81LF807KF8,07KFC7JF001FI01FCL0FE007LFJ01F800NF81LF807KFC,0LFCKF807EI01FEL0FE007KFEJ03FC007MF83LF807KFE,0LF9KFE1FCI01FEK01FE007CO03FCK03EJ01EM07CI07F,1LF1NF8I01FFK03FE007CO07FCK01EJ01EM07CI03F8,1JFDF1NFJ01FFK03FE007CO079EK03EJ01EM07CI01F8,3JF9E1MFEJ01FF8J07FE007CO079EK01EJ01FM07CJ0FC,3JF3E3MFEJ01FF8J07FE007CO0F9FK01EJ01FM07CJ07C,3IFE7C3MFEJ01F7CJ0FBE007CO0F0FK03EJ03FM07CJ07C,7IFE7C3NFJ01F7EJ0FBE007CN01F0FK03EJ03FM07CJ07C,7IFE7C3NFJ01F3EI01F3E007CN01E0F8J03EJ03EM07CJ03C,7IFC7C3NFJ01F1FI03F3E007CN01E078J03EJ03EM07CJ07C,JFC781NFJ01F1FI03E3E007CN03C07CJ03EJ03FM07CJ07C,JFC781FFCKFJ01F0F8007E3E007CN03C07CJ03EJ03FM07CJ07C,JFC381FF8KF8I01F0F8007C3E007CN07C03EJ03FJ01EM07CJ07C,JFE180FF8KF8I01F07C00F83E007CN07803EJ03EJ01FM07CJ07C,IFBEI0FF8KF8I01F07E00F83E007KFJ0F801EJ03EJ03KFC007CJ0FC,IFDFI07F87JF8I01F03E01F03E007KF8I0F801EJ01EJ03KFC007CJ0F8,IFCFI03F83JF8I01F01F01F03E007KF8I0FI0FJ03EJ03KFE007CI03F8,IFEF8001FC3JF8I01F01F03E03E007KF8001FI0F8I03EJ03KFE007CI07F,IFEFCI0FC1JF8I01F01F83E03E007C02K01EI0F8I03FJ03F0081I07KFE,IFEFEI03E0JF8I01F00F87C03E007CM03EI078I03EJ03FM07KFC,IFEFF8001F07IF8I01F007CFC03E007CM03EI07CI03EJ01EM07KF8,IFCFFEI0783IF8I01F007CF803E007CM03KFCI03EJ01FM07JFE,IFCIFI03C1IF8I01F003FF803E007CM07KFEI03EJ01FM07C207E,7FFCIFC001C0IFJ01F003FF003E007CM07KFEI03EJ01EM07C003E,7FF9F87EI0E07FFJ01F001FE003E007CM0LFEI03FJ01FM07C003F,7FF9E01F800303FFJ01F001FE003E007CM0F8I03FI03EJ01FM07C001F8,7FF1C00FC00301FFJ01FI0FC003E007CM0F8I01FI03EJ03EM07CI0F8,3FE38E07C00181FEJ01FI07C003E007CL01FJ01F8003EJ01FM07CI0FC,3FE39F03EI080FEJ01FI078003E007CL01FK0F8003EJ01FM07CI07E,1FC39F81EI0C0FCJ01FI038003E007CL03FK0F8003EJ03EM07CI03E,1FC3DF81EI040FCJ01FM03E007CL03EK07C001EJ01EM07CI03F,1F83DF80CI04078J01FM03E007CL03EK07C003EJ01EM07CI01F8,0F83FF80CI04078J01FM03E007FDCE7C07CK07E001FJ01F7FCE7807CI01F8,0781FF8K0407K01FM03E007LF07CK03E003EJ01LFC07CJ0FC,0701FFL0407K01FM03E007LF0FCK03E001EJ01LFC07CJ07C,03007EL0406K01FM03E007LF0F8K01F003EJ01LFC07CJ07E,030018L0404K01FM03E007LF0F8K01F003EJ01LFC07CJ03F,01P080C,R0808,,:^FS', result
    )
  end
end
