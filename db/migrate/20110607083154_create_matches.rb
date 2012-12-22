class CreateMatches < ActiveRecord::Migration
  def self.up
    create_table :matches do |t|
      t.integer :match_number
      t.integer :match_type
      t.string :match_dates
      t.string :team1_name
      t.string :team2_name
      t.string :ground
      t.string :season
      t.string :series

      t.timestamps
    end
  end

  def self.down
    drop_table :matches
  end
end
