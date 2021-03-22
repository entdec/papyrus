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
        pdf = Labelary::Label.render(zpl: @paper.attachment.download, content_type: 'application/pdf', dpmm: 8,
                                     width: 4, height: 6)

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
        paper.update(owner: Current.user)
        paper.attachment.attach @paper.attachment.blob
        paper.save!
      end
    end

    private

    def set_objects
      @paper = Paper.find(params[:id])
    end
  end
end
