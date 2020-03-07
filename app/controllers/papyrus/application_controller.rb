# frozen_string_literal: true

module Papyrus
  class ApplicationController < Papyrus.config.base_controller.constantize
    protect_from_forgery with: :exception
  end
end
