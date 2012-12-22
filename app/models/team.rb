class Team < ActiveRecord::Base
  has_many :innings
  has_many :players, :through => :innings, :uniq => true

  has_many :matches, :through => :innings, :uniq => true

#  has_many :matches, :finder_sql => Proc.new {
#    %Q{
#      SELECT *
#      FROM matches
#      WHERE (team1_id = #{id} and team2_id != #{id})
#        OR (team2_id = #{id} and team1_id != #{id})
#      ORDER BY m.start_date
#    }
#  }, :counter_sql => Proc.new {
#    %Q{
#      SELECT COUNT(*)
#      FROM matches
#      WHERE (team1_id = #{id} and team2_id != #{id})
#        OR (team2_id = #{id} and team1_id != #{id})
#    }
#  }

  has_many :grounds

  extend FriendlyId
  friendly_id :name, :use => :slugged

end
