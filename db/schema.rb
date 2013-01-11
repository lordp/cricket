# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130111025809) do

  create_table "fielders", :force => true do |t|
    t.integer  "inning_id"
    t.integer  "player_id"
    t.integer  "involvement"
    t.boolean  "substitute"
    t.boolean  "captain"
    t.boolean  "keeper"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "grounds", :force => true do |t|
    t.string   "name"
    t.string   "nickname"
    t.integer  "team_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "innings", :force => true do |t|
    t.integer  "player_id"
    t.integer  "match_id"
    t.integer  "inning_number"
    t.integer  "inning_type"
    t.string   "dismissal_text"
    t.integer  "runs"
    t.integer  "minutes"
    t.integer  "balls"
    t.integer  "fours"
    t.integer  "sixes"
    t.decimal  "overs",                      :precision => 5, :scale => 1
    t.integer  "maidens"
    t.integer  "wickets"
    t.integer  "wides"
    t.integer  "noballs"
    t.integer  "byes"
    t.integer  "legbyes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "penalty"
    t.integer  "dismissal_bowler_id"
    t.integer  "dismissal_fielder_id"
    t.integer  "dismissal_other_fielder_id"
    t.text     "extras"
    t.integer  "team_id"
    t.integer  "dismissal_type"
    t.boolean  "captain"
    t.boolean  "keeper"
    t.boolean  "fielder_is_captain"
    t.boolean  "fielder_is_keeper"
    t.boolean  "fielder_is_sub"
  end

  create_table "match_teams", :force => true do |t|
    t.integer  "match_id"
    t.integer  "team_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "match_teams", ["match_id", "team_id"], :name => "match_team"

  create_table "matches", :force => true do |t|
    t.integer  "match_number"
    t.integer  "match_type"
    t.string   "match_dates"
    t.string   "team1_name"
    t.string   "team2_name"
    t.string   "ground"
    t.string   "season"
    t.string   "series"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cricinfo_id"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "team1_id"
    t.integer  "team2_id"
    t.integer  "ground_id"
  end

  create_table "news", :force => true do |t|
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "players", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cricinfo_id"
    t.text     "full_name"
    t.text     "slug"
  end

  add_index "players", ["slug"], :name => "index_players_on_slug", :unique => true

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "slug"
  end

end
