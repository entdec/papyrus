# frozen_string_literal: true

module Papyrus
  class Template < ApplicationRecord
    include Papyrus::Concerns::MetadataScoped

    def render(context)
      template = Tilt::PrawnTemplate.new(metadata.deep_symbolize_keys) { |_t| data }
      template.render(Papyrus::Context.new(self), data: context)
    end
  end
end
