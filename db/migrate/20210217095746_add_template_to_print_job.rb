class AddTemplateToPrintJob < ActiveRecord::Migration[6.0]
  def change
    add_reference :papyrus_print_jobs, :paper, type: :uuid, null: false, foreign_key: { to_table: :papyrus_papers }
  end
end
