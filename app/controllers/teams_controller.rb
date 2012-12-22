class TeamsController < ApplicationController
  caches_page :show, :gzip => true

  # GET /teams
  # GET /teams.json
  def index
    @teams = Team.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @teams }
    end
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
    @team = Team.find(params[:id])
    logger.info("HELLO - #{@team.matches.class}")
    @matches = @team.matches.page(params[:page]).per(25)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @team }
    end
  end
end
