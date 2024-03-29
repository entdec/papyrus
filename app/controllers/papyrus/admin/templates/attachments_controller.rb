# frozen_string_literal: true

require_dependency 'papyrus/application_admin_controller'

module Papyrus
  module Admin
    module Templates
      class AttachmentsController < ApplicationAdminController
        before_action :set_objects

        def show
          attachment = @template.attachments.find_by(id: params[:id])
          send_data attachment.blob.download, type: attachment.content_type, disposition: 'attachment',
                                              filename: attachment.blob.filename.to_s
        end

        def index; end

        def create
          params[:attachments].each do |file|
            @template.attachments.attach(file)
          end
        end

        def destroy
          attachment = @template.attachments.find_by(id: params[:id])
          attachment.purge if attachment
          render :create
        end

        private

        def set_objects
          @template = Papyrus::Template.visible.find(params[:template_id])
        end
      end
    end
  end
end
