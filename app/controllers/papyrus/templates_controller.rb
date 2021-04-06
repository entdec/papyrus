# frozen_string_literal: true

module Papyrus
  class TemplatesController < ApplicationController
    protect_from_forgery with: :exception
    skip_before_action :verify_authenticity_token

    def paper
      template = Template.find(params[:id])

      if request.get? && !params[:context]
        example_data = HashWithIndifferentAccess.new(template.example_data)
        ctx = example_data[:context]
        locale = example_data[:locale]
      else
        ctx = params[:context].permit!
        locale = params[:locale]
      end

      _paper, data = template.generate(nil, ctx.reject { |h| h == 'pdf' }, locale: locale)

      send_data data.read, type: 'application/pdf', disposition: 'inline', filename: template.file_name
    end
  end
end
