class AddFieldsToInnings < ActiveRecord::Migration
  def change
    add_column :innings, :captain, :boolean
    add_column :innings, :keeper, :boolean
    add_column :innings, :fielder_is_captain, :boolean
    add_column :innings, :fielder_is_keeper, :boolean
    add_column :innings, :fielder_is_sub, :boolean
  end
end
