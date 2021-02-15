# frozen_string_literal: true

require_dependency 'papyrus/application_admin_controller'

module Papyrus
  module Admin
    class TemplatesController < ApplicationAdminController
      before_action :set_objects, except: [:index]

      def index; end

      def new
        @template = Papyrus::Template.new
        render :edit
      end

      def create
        @template = Papyrus::Template.new(template_params)
        respond @template.save
      end

      def edit
        @template = Papyrus::Template.visible.find(params[:id])
      end

      def show
        redirect_to :edit_admin_template
      end

      def update
        @template = Papyrus::Template.visible.find(params[:id])
        respond @template.update(template_params), action: :edit
      end

      def destroy
        @template = Papyrus::Template.visible.find(params[:id])
        respond @template.destroy, notice: 'The template was deleted',
                                   error: 'There were problems deleting the template'
      end

      def purge_attachment
        @template = Papyrus::Template.visible.find(params[:id])
        attachment = @template.attachments.find_by(id: params[:attachment_id])
        attachment.purge if attachment
      end

      private

      def set_objects; end

      def template_params
        params.require(:template).permit(:description, :metadata, :data, :example_data, :klass, :event,
                                         attachments: []).tap do |w|
          w[:metadata] = YAML.safe_load(params[:template][:metadata])
          w[:example_data] = ::JSON.parse(params[:template][:example_data])
        end
      end
    end
  end
end
