module Papyrus
  class Event < ApplicationRecord
    belongs_to :transitionable, polymorphic: true
  end
end
