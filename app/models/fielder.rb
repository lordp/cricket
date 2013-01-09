class Fielder < ActiveRecord::Base
  attr_accessible :captain, :inning_id, :involvement, :keeper, :player_id, :substitute
  belongs_to :inning
  belongs_to :player

  BOWLER  = 0
  FIELDER = 1

  def self.populate(inning_id, player, involvement)
    self.find_or_create_by_inning_id_and_player_id_and_involvement(
      inning_id, player[:id], involvement, {
        :captain    => player[:captain],
        :keeper     => player[:keeper],
        :substitute => player[:substitute]
    }
    ).save
  end
end
