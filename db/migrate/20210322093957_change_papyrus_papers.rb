class ChangePapyrusPapers < ActiveRecord::Migration[6.0]
  def change
    change_column_null :papyrus_papers, :template_id, true
  end
end
