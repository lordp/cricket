class InningsController < ApplicationController
  def index
    if params[:runs]
      @innings = Inning.where(:inning_type => Inning::INNING_TYPE_BAT)

      if params[:runs] && !params[:runs].blank?
        @innings = @innings.where(:runs => params[:runs].to_i)
      end

      if params[:dismissed] && params[:dismissed] != 'both'
        @innings = @innings.where(:dismissal_text => 'not out') if params[:dismissed] == 'nots'
        @innings = @innings.where('dismissal_text <> ?', 'not out') if params[:dismissed] == 'outs'
      end

      if params[:dismissal_type] && !params[:dismissal_type].empty?
        @innings = @innings.where('dismissal_type IN (?)', params[:dismissal_type].map(&:to_i))
      end

      @innings = @innings.joins(:match).order('matches.start_date')
    end

    respond_to do |format|
      format.html
      format.json { render json: @innings }
    end
  end
end
