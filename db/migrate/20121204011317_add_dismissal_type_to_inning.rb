class AddDismissalTypeToInning < ActiveRecord::Migration
  def change
    add_column :innings, :dismissal_type, :text
  end
end
