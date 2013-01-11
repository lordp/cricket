class Player < ActiveRecord::Base

  has_many :innings
  has_many :teams, :through => :innings, :uniq => true

  extend FriendlyId
  friendly_id :full_name, :use => :slugged

  def victim_count(involvement)
    Fielder.joins(:inning).select('innings.player_id').where('fielders.player_id = ?', self.id).where('fielders.involvement = ?', involvement).group('innings.player_id').limit(5).count(:order => 'COUNT(innings.player_id) DESC')
  end

  def victim_count_as_batter(involvement)
    Inning.joins(:fielders).select('fielders.player_id').where('innings.player_id = ?', self.id).where('fielders.involvement = ?', involvement).group('fielders.player_id').limit(5).count(:order => 'COUNT(fielders.player_id) DESC')
  end
end
