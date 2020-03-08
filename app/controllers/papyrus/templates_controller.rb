# frozen_string_literal: true

module Papyrus
  class TemplatesController < ApplicationController
    protect_from_forgery with: :exception
    skip_before_action :authenticate_user!
    skip_before_action :verify_authenticity_token

    def paper
      send_data Template.find(params[:id]).render(params[:data]), type: 'application/pdf', disposition: 'inline'
    end
  end
end
