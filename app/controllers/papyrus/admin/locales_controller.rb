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
        @locale.save
        respond_with :admin, @locale
      end

      def show
        redirect_to :edit_admin_locale
      end

      def edit
        @locale = Papyrus::Locale.visible.find(params[:id])
      end

      def update
        @locale = Papyrus::Locale.visible.find(params[:id])
        @locale.update(locale_params)
        respond_with :admin, @locale
      end

      private

      def set_objects; end

      def locale_params
        params.require(:locale).permit(:key, :data_yaml, :metadata_yaml)
      end
    end
  end
end
