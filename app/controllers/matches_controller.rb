class MatchesController < ApplicationController
  def index
    if params[:team_id]
      @team = Team.find(params[:team_id])
      @matches = @team.matches.order(:start_date).page(params[:page]).per(25)
    else
      @matches = Match.order(:start_date).page(params[:page]).per(25)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @matches }
    end
  end

  def show
    @match = Match.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @match }
    end
  end
end
