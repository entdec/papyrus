# frozen_string_literal: true

require_dependency 'papyrus/application_controller'

module Papyrus
  class PapersController < ApplicationController
    protect_from_forgery with: :exception
    before_action :set_objects

    def show
      if @paper.kind == 'pdf'
        redirect_to main_app.rails_blob_path(@paper.attachment, disposition: 'inline')
      else
        metadata = @paper.metadata.present? ? @paper.metadata : @paper.template&.metadata

        pdf = Labelary::Label.render(zpl: @paper.attachment.download,
                                     content_type: 'application/pdf',
                                     dpmm: metadata&.dig('dpmm') || 8,
                                     width: metadata&.dig('width') || 4,
                                     height: metadata&.dig('height') || 8)

        send_data pdf,
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end

    def print
      if @paper.owner == Current.user
        @paper.print!
      else
        paper = @paper.dup
        paper.owner = Current.user
        paper.attachment.attach @paper.attachment.blob
        paper.save!
      end
    end

    def regenerate
      if @paper.template && @paper.papyrable && @paper.template.event
        Papyrus.event(@paper.template.event, @paper.papyrable,
                      options: { template_id: @paper.template_id, owner: Current.user })
      end
    end

    private

    def set_objects
      @paper = Paper.find(params[:id])
    end
  end
end
