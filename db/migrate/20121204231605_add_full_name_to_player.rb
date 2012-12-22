class AddFullNameToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :full_name, :text
  end
end
