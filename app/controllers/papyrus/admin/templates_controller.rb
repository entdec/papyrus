# frozen_string_literal: true

require_dependency 'papyrus/application_admin_controller'

module Papyrus
  module Admin
    class TemplatesController < ApplicationAdminController
      before_action :set_objects, except: [:index]
      before_action :set_template_and_version, only: [:rollback]

      def index; end

      def new
        @template = Papyrus::Template.new
        render :edit
      end

      def create
        @template = Papyrus::Template.new(template_params)
        @template.save
        respond_with :admin, @template
      end

      def edit
        @template = Papyrus::Template.visible.find(params[:id])
      end

      def show
        redirect_to :edit_admin_template
      end

      def update
        @template = Papyrus::Template.visible.find(params[:id])
        @template.update(template_params)
        PaperTrail::Version.where('created_at < ?', 1.year.ago).delete_all
        respond_with :admin, @template
      end

      def destroy
        @template = Papyrus::Template.visible.find(params[:id])
        @template.destroy
        respond_with :admin, @template
      end

      def purge_attachment
        @template = Papyrus::Template.visible.find(params[:id])
        attachment = @template.attachments.find_by(id: params[:attachment_id])
        attachment.purge if attachment
      end

      def rollback
        reverted_template = @version.reify
        @template.update(reverted_template.attributes)
        respond_with :admin, @template
      end

      private

      def set_template_and_version
        @template = Papyrus::Template.visible.find(params[:id])
        @version = @template.versions.find(params[:version_id])
      end

      def set_objects; end

      def template_params
        params.require(:template).permit(:enabled, :description, :metadata, :data, :condition, :file_name_template, :example_data, :use, :purpose, :kind, :copies, :klass, :event).tap do |w|
            w[:metadata] = YAML.safe_load(params[:template][:metadata])
            w[:example_data] = ::JSON.parse(params[:template][:example_data])
        end
      end
    end
  end
end
