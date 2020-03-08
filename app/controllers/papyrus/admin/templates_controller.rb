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
        respond @template.destroy, notice: 'The template was deleted', error: 'There were problems deleting the template'
      end

      private

      def set_objects; end

      def template_params
        params.require(:template).permit(:description, :metadata, :data, attachments: []).tap do |w|
          w[:metadata] = YAML.safe_load(params[:template][:metadata])
        end
      end
    end
  end
end
