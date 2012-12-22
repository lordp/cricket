class AddDismissalFields < ActiveRecord::Migration
  def self.up
    add_column :innings, :dismissal_bowler, :string
  end

  def self.down
    remove_column :innings, :dismissal_bowler
  end
end
