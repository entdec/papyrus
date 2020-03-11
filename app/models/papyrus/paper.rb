# frozen_string_literal: true

module Papyrus
  class Paper < ApplicationRecord
    belongs_to :template
  end
end
