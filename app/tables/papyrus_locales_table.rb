# frozen_string_literal: true

class PapyrusLocalesTable < ActionTable::ActionTable
  model Papyrus::Locale

  column(:key)
  column(:metadata) { |locale| Papyrus.config.metadata_humanize(locale.metadata) }

  initial_order :key

  row_link { |locale| papyrus.edit_admin_locale_path(locale) }

  private

  def scope
    @scope = Papyrus::Locale.visible
  end
end
