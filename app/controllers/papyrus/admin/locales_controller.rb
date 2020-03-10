# frozen_string_literal: true

require_dependency 'papyrus/application_admin_controller'

module Papyrus
  module Admin
    class LocalesController < ApplicationAdminController
      def index
        @locales = Papyrus::Locale.visible.order(:key)
      end

      def new
        @locale = Papyrus::Locale.new
        render :edit
      end

      def create
        @locale = Papyrus::Locale.new(locale_params)
        respond @locale.save
      end

      def show
        redirect_to :edit_admin_locales
      end

      def edit
        @locale = Papyrus::Locale.visible.find(params[:id])
      end

      def update
        @locale = Papyrus::Locale.visible.find(params[:id])
        respond @locale.update(locale_params), action: :edit
      end

      private

      def set_objects; end

      def locale_params
        params.require(:locale).permit(:key, :data, :metadata).tap do |w|
          w[:data] = YAML.safe_load(params[:locale][:data])
          w[:metadata] = YAML.safe_load(params[:locale][:metadata])
        end
      end
    end
  end
end
