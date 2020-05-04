# frozen_string_literal: true

module Papyrus
  class Paper < ApplicationRecord
    belongs_to :template

    has_one_attached :attachment
  end
end
