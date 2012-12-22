class AddCricinfoIdToMatches < ActiveRecord::Migration
  def self.up
    add_column :matches, :cricinfo_id, :integer
  end

  def self.down
    remove_column :matches, :cricinfo_id
  end
end
