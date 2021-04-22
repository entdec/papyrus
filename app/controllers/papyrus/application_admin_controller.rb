# frozen_string_literal: true

require_dependency 'papyrus/application_controller'

module Papyrus
  class ApplicationAdminController < ApplicationController
    include Papyrus.config.admin_authentication_module.constantize if Papyrus.config.admin_authentication_module
  end
end
