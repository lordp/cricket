class Inning < ActiveRecord::Base

  INNING_TYPE_BAT  = 0
  INNING_TYPE_BOWL = 1

  DISMISSAL_TYPE_CAUGHT = 0
  DISMISSAL_TYPE_BOWLED = 1
  DISMISSAL_TYPE_STUMPED = 2
  DISMISSAL_TYPE_LBW = 3
  DISMISSAL_TYPE_RUN_OUT = 4
  DISMISSAL_TYPE_HIT_WICKET = 5

  DISMISSAL_TYPE_RETIRED_HURT = 6
  DISMISSAL_TYPE_RETIRED_OUT = 7
  DISMISSAL_TYPE_RETIRED_NOT_OUT = 8
  DISMISSAL_TYPE_RETIRED_ILL = 9

  DISMISSAL_TYPE_ABSENT = 10
  DISMISSAL_TYPE_ABSENT_HURT = 11
  DISMISSAL_TYPE_ABSENT_ILL = 12

  DISMISSAL_TYPE_HANDLED_THE_BALL = 13
  DISMISSAL_TYPE_OBSTRUCTING_THE_FIELD = 14

	attr_accessible :inning_number, :match_id, :player_id

  belongs_to :match
	belongs_to :player
  belongs_to :team

  delegate :name, :to => :team, :prefix => true, :allow_nil => true

  belongs_to :dismissal_bowler, :class_name => 'Player'
  belongs_to :dismissal_fielder, :class_name => 'Player'
  belongs_to :dismissal_other_fielder, :class_name => 'Player'

  has_many :fielders, :dependent => :destroy

  before_save :split_extras, :fix_dismissal

  scope :batting_innings, where(:inning_type => Inning::INNING_TYPE_BAT)
  scope :bowling_innings, where(:inning_type => Inning::INNING_TYPE_BOWL)

  def fix_dismissal
    dismissals = {
      :caught                => /^c (\u2020?.+?) b (.+)$/,
      :bowled                => /^b (.+)$/,
      :lbw                   => /^lbw b (.+)$/,
      :hitwicket             => /^hit wicket b (.+)$/,
      :runout                => /^run out (\([^\)]+\))/,
      :stumped               => /^st (\u2020?.+?) b (.+)$/,
      :retired               => /^retired (hurt|out|not out|ill)/,
      :absent                => /^absent (hurt|ill)/,
      :handled_the_ball      => /^handled the ball/,
      :obstructing_the_field => /^obstructing the field/
    }

    dismissals.each do |type, regex|
      self.send(type, self.dismissal_text.match(regex)) if !self.dismissal_text.nil? && self.dismissal_text.match(regex)
    end

    self
  end

  def caught(dismissal)
    self.dismissal_type = DISMISSAL_TYPE_CAUGHT

    if bowler = self.find_player(dismissal.captures.last)
      Fielder.find_or_create_by_player_id_and_inning_id(bowler[:id], self.id, {
        :captain     => bowler[:captain],
        :keeper      => bowler[:keeper],
        :involvement => Fielder::BOWLER,
      }).save
    end

    if dismissal.captures.first.match(/^sub \(([^\)]+)\)/)
      if fielder = self.find_player($~[1])
        Fielder.find_or_create_by_player_id_and_inning_id(fielder[:id], self.id, {
          :captain     => fielder[:captain],
          :keeper      => fielder[:keeper],
          :substitute  => true,
          :involvement => Fielder::FIELDER,
        }).save
      end
    elsif dismissal.captures.first == '&'
      if fielder = self.find_player(dismissal.captures[1])
        Fielder.populate(self.id, fielder, Fielder::FIELDER)
      end
    else
      if fielder = self.find_player(dismissal.captures.first)
        Fielder.find_or_create_by_player_id_and_inning_id(fielder[:id], self.id, {
          :captain     => fielder[:captain],
          :keeper      => fielder[:keeper],
          :involvement => Fielder::FIELDER,
        }).save
      end
    end
  end

  def bowled(dismissal)
    self.dismissal_type = DISMISSAL_TYPE_BOWLED
    if bowler = self.find_player(dismissal.captures.first)
      Fielder.find_or_create_by_player_id_and_inning_id(bowler[:id], self.id, {
        :captain     => bowler[:captain],
        :keeper      => bowler[:keeper],
        :involvement => Fielder::BOWLER,
      }).save
    end
  end

  def lbw(dismissal)
    self.dismissal_type = DISMISSAL_TYPE_LBW
    if bowler = self.find_player(dismissal.captures.first)
      Fielder.find_or_create_by_player_id_and_inning_id(bowler[:id], self.id, {
        :captain     => bowler[:captain],
        :keeper      => bowler[:keeper],
        :involvement => Fielder::BOWLER,
      }).save
    end
  end

  def hitwicket(dismissal)
    self.dismissal_type = DISMISSAL_TYPE_HIT_WICKET
    if bowler = self.find_player(dismissal.captures.first)
      Fielder.find_or_create_by_player_id_and_inning_id(bowler[:id], self.id, {
        :captain     => bowler[:captain],
        :keeper      => bowler[:keeper],
        :involvement => Fielder::BOWLER,
      }).save
    end
  end

  def runout(dismissal)
    self.dismissal_type = DISMISSAL_TYPE_RUN_OUT
    players = dismissal.captures.first.gsub(/[()]/, '').split(/\//)
    puts players.inspect

    if players.first.match(/^sub \[([^\]]+)\]/)
      if fielder = self.find_player($~[1])
        Fielder.find_or_create_by_player_id_and_inning_id(fielder[:id], self.id, {
          :captain     => false,
          :keeper      => fielder[:keeper],
          :substitute  => true,
          :involvement => Fielder::FIELDER,
        }).save
      end
    else
      if fielder = self.find_player(players.first)
        puts fielder.inspect
        Fielder.find_or_create_by_player_id_and_inning_id(fielder[:id], self.id, {
          :captain     => fielder[:captain],
          :keeper      => fielder[:keeper],
          :involvement => Fielder::FIELDER,
        }).save
      end
    end

    if players.count > 1 && fielder = self.find_player(players.last)
      puts fielder.inspect
      Fielder.find_or_create_by_player_id_and_inning_id(fielder[:id], self.id, {
        :captain     => fielder[:captain],
        :keeper      => fielder[:keeper],
        :substitute  => fielder[:substitute],
        :involvement => Fielder::FIELDER,
      }).save
    end
  end

  def stumped(dismissal)
    self.dismissal_type = DISMISSAL_TYPE_STUMPED
    if bowler = self.find_player(dismissal.captures.last)
      puts bowler.inspect
      Fielder.find_or_create_by_player_id_and_inning_id(bowler[:id], self.id, {
        :captain     => bowler[:captain],
        :involvement => Fielder::BOWLER,
      }).save
    end

    if fielder = self.find_player(dismissal.captures.first)
      puts fielder.inspect
      Fielder.find_or_create_by_player_id_and_inning_id(fielder[:id], self.id, {
        :captain     => fielder[:captain],
        :keeper      => fielder[:keeper],
        :substitute  => fielder[:substitute],
        :involvement => Fielder::FIELDER,
      }).save
    end
  end

  def retired(dismissal)
    self.dismissal_type = case dismissal.captures.first
      when 'hurt' then DISMISSAL_TYPE_RETIRED_HURT
      when 'out' then DISMISSAL_TYPE_RETIRED_OUT
      when 'not out' then DISMISSAL_TYPE_RETIRED_NOT_OUT
      when 'ill' then DISMISSAL_TYPE_RETIRED_ILL
      else nil
    end
  end

  def absent(dismissal)
    self.dismissal_type = case dismissal.captures.first
      when 'hurt' then DISMISSAL_TYPE_ABSENT_HURT
      when 'ill' then DISMISSAL_TYPE_ABSENT_ILL
      else nil
    end
  end

  def handled_the_ball(dismissal)
    self.dismissal_type = DISMISSAL_TYPE_HANDLED_THE_BALL
  end

  def obstructing_the_field(dismissal)
    self.dismissal_type = DISMISSAL_TYPE_OBSTRUCTING_THE_FIELD
  end

  def find_player(name)
    # look for players in the same match
    name.gsub!(/[\u2020\*]/, '')
    players = self.match.innings.joins(:player).where('players.name like ?', "%#{name}%")
    if players.empty?
      # try looking across the entire player catalogue
      player = Player.where('name like ?', "%#{name}%").first
      inning = {}
    else
      player = players.first.player
      inning = { :captain => players.first.captain, :keeper => players.first.keeper }
    end

    player.nil? ? nil : { :id => player.id }.update(inning)
  end

  def split_extras
    unless self.extras.blank?
      self.extras.gsub(/[()]/, '').split(/, /).each do |e|
        full, number, type = e.match(/([\d]+)([ln]?b|w|pen)/).to_a
        self.send("#{type}=", number)
      end
    end

    unless self.dismissal_text.blank?
      self.dismissal_text.gsub(/[()]/, '').split(/, /).each do |e|
        full, type, number = e.match(/([ln]?b|w|pen) ([\d]+)/).to_a
        self.send("#{type}=", number) unless type.blank?
      end
    end
  end

  def not_out?
    self.dismissal_text == 'not out'
  end

  private

    def w=(w)
      self.wides = w
    end

    def b=(b)
      self.byes = b
    end

    def lb=(lb)
      self.legbyes = lb
    end

    def nb=(nb)
      self.noballs = nb
    end

    def pen=(pen)
      self.penalty = pen
    end

end
