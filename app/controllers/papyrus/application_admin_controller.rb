# frozen_string_literal: true

require_dependency 'papyrus/application_controller'

module Papyrus
  class ApplicationAdminController < ApplicationController
    include Nuntius::Concerns::Respond
    include Nuntius.config.admin_authentication_module.constantize if Nuntius.config.admin_authentication_module
  end
end
