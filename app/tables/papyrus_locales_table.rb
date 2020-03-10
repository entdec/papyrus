# frozen_string_literal: true

class PapyrusLocalesTable < ActionTable::ActionTable
  model Papyrus::Locale

  column(:key)
  column(:metadata) { |locale| Papyrus.config.metadata_humanize(locale.metadata) }

  initial_order :mkey, :asc

  row_link { |locale| papyrus.edit_admin_locale_path(locale) }

  private

  def scope
    @scope = Papyrus::Locale.visible
  end

  def filtered_scope
    @filtered_scope = scope

    @filtered_scope
  end
end
