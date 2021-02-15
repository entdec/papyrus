class AddPapyrableToPaper < ActiveRecord::Migration[6.0]
  def change
    add_reference :papyrus_papers, :papyrable, null: true, polymorphic: true, index: false, type: :uuid,
                                               foreign_key: false

    add_column :papyrus_templates, :klass, :string
    add_column :papyrus_templates, :event, :string
  end
end
