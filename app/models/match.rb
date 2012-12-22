class Match < ActiveRecord::Base

  MATCH_TYPE_TEST = 0
  MATCH_TYPE_ODI  = 1

	has_many :innings
  has_many :players, :through => :innings

  belongs_to :team1, :class_name => 'Team'
  belongs_to :team2, :class_name => 'Team'

  belongs_to :ground

  before_save :calculate_match_dates

  attr_accessible :start_date, :end_date

  def calculate_match_dates
    unless self.match_dates.nil?
      match_date_regex = self.match_dates.match(/(\d+)((,[ ]?\d+)*)(,?[ ]+)([A-Za-z]+)( \d+)?(, (\d+)((,\d+)*)(,?[ ]+)([A-Za-z]+)[ ]+(\d+)|[ ]+(\d+))/)
      if match_date_regex[14].nil?
        if match_date_regex[6].nil?
          self.start_date = Date.parse("#{match_date_regex[1]} #{match_date_regex[5]} #{match_date_regex[13]}")
          if match_date_regex[10].nil?
            self.end_date = Date.parse("#{match_date_regex[8].gsub(/[^\d]/, '').to_i} #{match_date_regex[12]} #{match_date_regex[13]}")
          else
            self.end_date = Date.parse("#{match_date_regex[10].gsub(/[^\d]/, '').to_i} #{match_date_regex[12]} #{match_date_regex[13]}")
          end
        else
          self.start_date = Date.parse("#{match_date_regex[1]} #{match_date_regex[5]} #{match_date_regex[6]}")
          if match_date_regex[10].nil?
            self.end_date = Date.parse("#{match_date_regex[8].gsub(/[^\d]/, '').to_i} #{match_date_regex[12]} #{match_date_regex[13]}")
          else
            self.end_date = Date.parse("#{match_date_regex[10].gsub(/[^\d]/, '').to_i} #{match_date_regex[12]} #{match_date_regex[13]}")
          end
        end
      else
        self.start_date = Date.parse("#{match_date_regex[1]} #{match_date_regex[5]} #{match_date_regex[14]}")
        self.end_date   = Date.parse("#{match_date_regex[3].gsub(/[^\d]/, '').to_i} #{match_date_regex[5]} #{match_date_regex[14]}")
      end
    end
  end

end
