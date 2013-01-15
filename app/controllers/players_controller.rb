class PlayersController < ApplicationController
  caches_page :bowling_innings, :batting_innings, :gzip => true

  # GET /players
  # GET /players.json
  def index
    if params[:team_id].nil?
      @players = Player.order(:full_name)
    else
      @team = Team.find(params[:team_id])
      @players = @team.players.order(:full_name)
    end

    unless params[:search].blank?
      @players = @players.where('full_name ilike ?', "%#{params[:search]}%")
    end

    @players.reject! { |p| p.id == 12 }

    respond_to do |format|
      format.html do
        @players = @players.page(params[:page]).per(25)
      end
      format.json { render json: @players }
    end
  end

  # GET /players/1
  # GET /players/1.json
  def show
    @player = Player.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @player }
    end
  end

  def search
    @term = params[:term]
    @players = Player.where('name ilike ?', "%#{params[:term]}%")

    respond_to do |format|
      format.html # search.html.erb
      format.json { render json: @players }
    end
  end

  def chart
    @player = Player.find(params[:id])

    respond_to do |format|
      format.html # search.html.erb
    end
  end

  def batting_innings
    @player          = Player.find(params[:id])
    @innings         = @player.innings.batting_innings.includes(:match).order('matches.match_number')
    @dismissal_types = @player.innings.batting_innings.select(:dismissal_type).group(:dismissal_type).count.reject { |k,v| k.nil? }

    respond_to do |format|
      format.html
      format.json do
        innings = @innings.collect do |i|
          {
            :runs           => i.runs,
            :minutes        => i.minutes,
            :balls          => i.balls,
            :fours          => i.fours,
            :sixes          => i.sixes,
            :captain        => i.captain.blank? ? false : true,
            :keeper         => i.keeper.blank? ? false : true,
            :not_out        => i.not_out?,
            :date           => i.match.start_date,
            :inning_number  => i.inning_number,
            :dismissal_text => i.dismissal_text,
            :match_number   => i.match.match_number,
          }
        end

        require 'moving_averager'
        ma = MovingAverager.new(10)
        innings.each do |i|
          ma << i[:runs]
          i[:moving_average] = ma.to_s
        end

        render json: innings
      end
    end
  end

  def bowling_innings
    @player  = Player.find(params[:id])
    @innings = @player.innings.bowling_innings.includes(:match).order('matches.match_number')

    respond_to do |format|
      format.html
      format.json do
        innings = @innings.collect do |i|
          {
            :overs         => i.overs,
            :runs          => i.runs,
            :maidens       => i.maidens,
            :wickets       => i.wickets,
            :wides         => i.wides,
            :noballs       => i.noballs,
            :captain       => i.captain.blank? ? false : true,
            :keeper        => i.keeper.blank? ? false : true,
            :date          => i.match.start_date,
            :inning_number => i.inning_number,
            :match_number  => i.match.match_number,
          }
        end

        render json: innings
      end
    end
  end

end
