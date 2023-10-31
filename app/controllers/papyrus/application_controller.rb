# frozen_string_literal: true

module Papyrus
  class ApplicationController < Papyrus.config.base_controller.constantize
    self.responder = Auxilium::Responder
    respond_to :html

    protect_from_forgery with: :exception
    rescue_from ActiveRecord::RecordNotFound, with: :redirect_to_root

    private
    def redirect_to_root(_exception)
      Signum.error(current_user, text: t("errors.messages.no_access_redirecting"))
      redirect_to root_url, status: :see_other
    end
  end
end
