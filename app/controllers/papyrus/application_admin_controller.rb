# frozen_string_literal: true

require_dependency 'papyrus/application_controller'

module Papyrus
  class ApplicationAdminController < ApplicationController
    include Papyrus::Concerns::Respond
    if Papyrus.config.admin_authentication_module
      include Papyrus.config.admin_authentication_module.constantize
    end
  end
end
