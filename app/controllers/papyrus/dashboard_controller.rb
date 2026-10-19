# frozen_string_literal: true

require_dependency 'papyrus/application_admin_controller'

module Papyrus
  class DashboardController < ApplicationAdminController
    def show
      return unless params[:papyrable_type].present? && params[:papyrable_id].present?

      klass_name = params[:papyrable_type]
      return unless Papyrus.config.papyrable_class_names.include?(klass_name)

      @papyrable = klass_name.safe_constantize&.find_by(id: params[:papyrable_id])
    end
  end
end
