# frozen_string_literal: true

module Papyrus
  class Paper < ApplicationRecord
    belongs_to :template

    has_one_attached :attachment rescue nil # SAD, but for development mode this is needed? in production mode this seems not to work?
  end
end
