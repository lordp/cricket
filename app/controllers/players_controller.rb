class PlayersController < ApplicationController
  caches_page :bowling_innings, :batting_innings, :gzip => true

  # GET /players
  # GET /players.json
  def index
    if params[:search].blank?
      if params[:team_id].nil?
        @players = Player.order(:full_name).page(params[:page]).per(25)
      else
        @team = Team.find(params[:team_id])
        @players = @team.players.order(:full_name).page(params[:page]).per(25)
      end
    else
      @players = Player.where('full_name ilike ?', "%#{params[:search]}%").order(:full_name).page(params[:page]).per(25)
    end

    @players.reject! { |p| p.id == 12 }

    respond_to do |format|
      format.html # index.html.erb
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
    @player  = Player.find(params[:id])
    @innings = @player.innings.batting_innings.includes(:match).order('matches.match_number')

    respond_to do |format|
      format.html
      format.json { render json: @innings }
    end
  end

  def bowling_innings
    @player  = Player.find(params[:id])
    @innings = @player.innings.bowling_innings.includes(:match).order('matches.match_number')

    respond_to do |format|
      format.html
      format.json { render json: @innings }
    end
  end

end
