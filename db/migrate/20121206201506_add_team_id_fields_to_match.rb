class AddTeamIdFieldsToMatch < ActiveRecord::Migration
  def change
    add_column :matches, :team1_id, :integer
    add_column :matches, :team2_id, :integer
  end
end
