# frozen_string_literal: true

class AddExampleDataToPapyrusTemplate < ActiveRecord::Migration[6.0]
  def change
    add_column :papyrus_templates, :example_data, :jsonb, default: {}
  end
end
