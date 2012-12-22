class AddGroundIdToMatches < ActiveRecord::Migration
  def change
    add_column :matches, :ground_id, :integer
  end
end
