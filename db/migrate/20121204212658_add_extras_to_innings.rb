class AddExtrasToInnings < ActiveRecord::Migration
  def change
    add_column :innings, :extras, :text
  end
end
