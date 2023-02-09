# frozen_string_literal: true

require_dependency 'papyrus/application_controller'

module Papyrus
  class Api::EventsController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!

    layout false

    def create
      papyrus_params = params.except(:scope, :event, :context, :controller, :action).permit!.to_h

      obj = { params[:scope] => params[:context].permit!.to_h }
      generator = Papyrus::BaseGenerator.generator_for_obj(obj).new(
        obj, params[:event], papyrus_params
      )
      return unless generator.respond_to? params[:event].to_sym

      generator.call
      templates = generator.templates
      papers = []
      papers = generator.dispatch(templates) if templates.present?

      # FIXME: This breaks at more than one template ...
      papers.each do |paper, data|
        send_data data.read, type: 'application/pdf', disposition: 'inline', filename: paper.template.file_name(params[:context])
      end
    end
  end
end
