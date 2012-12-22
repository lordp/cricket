class AddCricinfoIdToPlayers < ActiveRecord::Migration
  def self.up
    add_column :players, :cricinfo_id, :integer
  end

  def self.down
    remove_column :players, :cricinfo_id
  end
end
