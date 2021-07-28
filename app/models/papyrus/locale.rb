# frozen_string_literal: true

module Papyrus
  class Locale < ApplicationRecord
    include Papyrus::Concerns::MetadataScoped
    include Papyrus::Concerns::Metadata

    def data_yaml=(yaml)
      write_attribute :data, YAML.safe_load(yaml.gsub("\t", '  '))
    end

    def data_yaml
      return '' if data.nil? || data.empty?

      YAML.dump(attributes['data'])
    end
  end
end
