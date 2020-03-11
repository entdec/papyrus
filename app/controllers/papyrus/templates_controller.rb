# frozen_string_literal: true

module Papyrus
  class TemplatesController < ApplicationController
    protect_from_forgery with: :exception
    skip_before_action :authenticate_user!
    skip_before_action :verify_authenticity_token

    def paper
      template = Template.find(params[:id])

      ctx = params[:context]
      locale = params[:locale]

      if request.get?
        example_data = HashWithIndifferentAccess.new(template.example_data)
        ctx = example_data[:context]
        locale = example_data[:locale]
      end

      data = I18n.with_locale(locale) do
        template.render(ctx)
      end

      send_data data, type: 'application/pdf', disposition: 'inline', filename: template.file_name
    end
  end
end
