# frozen_string_literal: true

Vorto.setup do |config|
  config.base_controller = "::ApplicationController"
  config.admin_authentication_module = "Auxilium::Concerns::AdminAuthenticated"

  config.logger = Rails.logger
end