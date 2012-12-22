class AddPenaltyFieldToInnings < ActiveRecord::Migration
  def self.up
    add_column :innings, :penalty, :integer
  end

  def self.down
    remove_column :innings, :penalty
  end
end
