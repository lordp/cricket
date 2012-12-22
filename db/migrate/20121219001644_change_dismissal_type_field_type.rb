class ChangeDismissalTypeFieldType < ActiveRecord::Migration
  def up
    change_column :innings, :dismissal_type, :integer
  end

  def down
    change_column :innings, :dismissal_type, :text
  end
end
