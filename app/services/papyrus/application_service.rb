# frozen_string_literal: true

module Papyrus
  class ApplicationService < Servitium::Service
    transactional true
    include Rails.application.routes.url_helpers
  end
end
