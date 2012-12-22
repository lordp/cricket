class AddTeamIdToInnings < ActiveRecord::Migration
  def change
    add_column :innings, :team_id, :integer
  end
end
