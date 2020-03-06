# frozen_string_literal: true

require 'rails/railtie'

module Draper
  class Railtie < Rails::Railtie
    initializer 'decoro.view_helpers' do
      ActionView::Base.include Decoro::Helpers
    end
  end
end
