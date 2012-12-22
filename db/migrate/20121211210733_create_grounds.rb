class CreateGrounds < ActiveRecord::Migration
  def change
    create_table :grounds do |t|
      t.string :name, :nickname
      t.integer :team_id
      t.timestamps
    end
  end
end
