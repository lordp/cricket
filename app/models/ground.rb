class Ground < ActiveRecord::Base
  belongs_to :team
  has_many :matches

  attr_accessible :name, :nickname, :team_id

  delegate :name, :to => :team, :prefix => true, :allow_nil => true

  default_scope includes(:team).order('grounds.name').order('teams.name')
end
