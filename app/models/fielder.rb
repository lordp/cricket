class Fielder < ActiveRecord::Base
  attr_accessible :captain, :inning_id, :involvement, :keeper, :player_id, :substitute
  belongs_to :inning
  belongs_to :player

  BOWLER  = 0
  FIELDER = 1
end
