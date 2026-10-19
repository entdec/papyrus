require 'test_helper'

module Papyrus
  class TemplatesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test 'calling /paper on the templates controller generates paperwork' do
      post "/papyrus/templates/#{papyrus_templates(:pdf).id}/paper", params: template_json, as: :json

      assert_response :success
      text = PDF::Inspector::Text.analyze(response.body)

      assert_equal text.strings[0], 'Commercial Invoice'
      assert_equal text.strings[1], 'TEST'
    end

    private

    def template_json(_options = {})
      hash = {
        locale: 'en',
        context: {
          item: {
            name: 'TEST'
          }
        }
      }

      hash.with_indifferent_access
    end
  end
end
