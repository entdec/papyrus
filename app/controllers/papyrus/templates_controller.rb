# frozen_string_literal: true

module Papyrus
  class TemplatesController < ApplicationController
    protect_from_forgery with: :exception

    def paper
      template = Template.find(params[:id]).render(params)
    end
  end
end
