require 'test_helper'

module Papyrus
  class TemplatesControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers
    include Rack::Test::Methods

    test 'calling /paper on the templates controller generates paperwork' do
      post "/papyrus/templates/#{papyrus_templates(:pdf).id}/paper", template_json.to_json,
           { 'CONTENT_TYPE' => 'application/json' }

      assert last_response.ok?
      text = PDF::Inspector::Text.analyze(last_response.body)

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
