# frozen_string_literal: true

module Papyrus
  class Paper < ApplicationRecord
    belongs_to :template
    belongs_to :papyrable, polymorphic: true, optional: true

    has_one_attached :attachment

    def print!
      # NO OP
    end
  end
end
