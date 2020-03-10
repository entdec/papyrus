# frozen_string_literal: true

module Papyrus
  class Locale < ApplicationRecord
    include Nuntius::Concerns::MetadataScoped
  end
end
