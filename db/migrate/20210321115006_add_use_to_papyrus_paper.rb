class AddUseToPapyrusPaper < ActiveRecord::Migration[6.0]
  def change
    add_column :papyrus_papers, :use, :string

    Papyrus::Paper.all.each do |p|
      p.use = p.template.use
    end
  end
end
