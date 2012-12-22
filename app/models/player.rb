class Player < ActiveRecord::Base

	has_many :innings
  has_many :teams, :through => :innings, :uniq => true

  extend FriendlyId
  friendly_id :full_name, :use => :slugged

end
