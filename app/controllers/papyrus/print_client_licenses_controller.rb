# frozen_string_literal: true

require_dependency 'papyrus/application_controller'

module Papyrus
  class PrintClientLicensesController < ApplicationController
    protect_from_forgery with: :exception
    skip_before_action :authenticate_user_from_token!
    skip_before_action :authenticate_user!

    def show
      licence_hash = Digest::SHA256.hexdigest(Papyrus.config.print_client_license_key + params[:timestamp])

      render inline: "#{Papyrus.config.print_client_license_owner}|#{licence_hash}"
    end
  end
end
