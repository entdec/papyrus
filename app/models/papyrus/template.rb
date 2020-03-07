# frozen_string_literal: true

module Papyrus
  class Template < ApplicationRecord
    include Nuntius::Concerns::MetadataScoped

    def render(context)
      template = Tilt::PrawnTemplate.new(metadata) { |_t| data }
      template.render(Papyrus::Context.new, context: context)
    end
  end
end
