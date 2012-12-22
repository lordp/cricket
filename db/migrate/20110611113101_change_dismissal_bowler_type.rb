class ChangeDismissalBowlerType < ActiveRecord::Migration
  def self.up
    remove_column :innings, :dismissal_bowler
    add_column :innings, :dismissal_bowler_id, :integer
  end

  def self.down
    remove_column :innings, :dismissal_bowler_id
    add_column :innings, :dismissal_bowler, :string
  end
end
