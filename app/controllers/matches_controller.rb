class MatchesController < ApplicationController
  def index
    @matches = Match.order(:start_date).page(params[:page]).per(25)

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
