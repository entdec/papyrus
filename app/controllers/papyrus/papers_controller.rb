# frozen_string_literal: true

require_dependency 'papyrus/application_controller'

module Papyrus
  class PapersController < ApplicationController
    protect_from_forgery with: :exception
    before_action :set_objects

    def print
      @paper.print!
    end

    private

    def set_objects
      @paper = Paper.find(params[:id])
    end
  end
end
