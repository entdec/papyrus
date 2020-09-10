# frozen_string_literal: true

module Papyrus
  class Locale < ApplicationRecord
    include Papyrus::Concerns::MetadataScoped
  end
end
