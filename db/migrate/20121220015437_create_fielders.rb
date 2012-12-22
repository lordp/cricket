class CreateFielders < ActiveRecord::Migration
  def change
    create_table :fielders do |t|
      t.integer :inning_id
      t.integer :player_id
      t.integer :involvement
      t.boolean :substitute
      t.boolean :captain
      t.boolean :keeper

      t.timestamps
    end
  end
end
