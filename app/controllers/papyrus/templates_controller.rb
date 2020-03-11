# frozen_string_literal: true

module Papyrus
  class TemplatesController < ApplicationController
    protect_from_forgery with: :exception
    skip_before_action :authenticate_user!
    skip_before_action :verify_authenticity_token

    def paper
      template = Template.find(params[:id])
      data = if request.post?
               params[:context]
             else
               HashWithIndifferentAccess.new(template.example_data)[:context]
             end
      send_data template.render(data), type: 'application/pdf', disposition: 'inline', filename: template.file_name
    end
  end
end
