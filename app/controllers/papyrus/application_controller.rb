# frozen_string_literal: true

module Papyrus
  class ApplicationController < Papyrus.config.base_controller.constantize
    self.responder = Auxilium::Responder
    respond_to :html

    protect_from_forgery with: :exception
  end
end
