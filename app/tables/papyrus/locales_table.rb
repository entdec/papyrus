# frozen_string_literal: true

module Papyrus
  class LocalesTable < Papyrus::ApplicationTable
    definition do
      model Papyrus::Locale
      supports_custom_views true
      show_header true
      exportable true
      internal :id

      column(:key) do
        filter do
          operator :matches
        end
      end
      column(:metadata) do
        render do
          html { |locale| Papyrus.config.metadata_humanize(locale.metadata) }
          csv { |locale| Papyrus.config.metadata_humanize(locale.metadata) }
        end
      end
      order key: :asc, id: :asc
      link { |locale| papyrus.edit_admin_locale_path(locale) }
    end

    def scope
      Papyrus::Locale.visible
    end
  end
end
