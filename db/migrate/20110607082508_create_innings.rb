class CreateInnings < ActiveRecord::Migration
  def self.up
    create_table :innings do |t|
      t.integer :player_id
      t.integer :match_id
      t.integer :inning_number
      t.integer :inning_type
      t.string :dismissal_type
      t.string :dismissed_by
      t.integer :runs
      t.integer :minutes
      t.integer :balls
      t.integer :fours
      t.integer :sixes
      t.decimal :overs, :precision => 5, :scale => 1
      t.integer :maidens
      t.integer :wickets
      t.integer :wides
      t.integer :noballs
      t.integer :byes
      t.integer :legbyes

      t.timestamps
    end
  end

  def self.down
    drop_table :innings
  end
end
