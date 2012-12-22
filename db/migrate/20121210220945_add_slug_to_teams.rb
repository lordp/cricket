class AddSlugToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :slug, :text
  end
end
