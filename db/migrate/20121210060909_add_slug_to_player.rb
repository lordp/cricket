class AddSlugToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :slug, :text
    add_index :players, :slug, :unique => true
  end
end
