module InningsHelper
  def show_dismissal(inning)
    unless inning.player.name == 'Extras'
      case inning.dismissal_type
        when Inning::DISMISSAL_TYPE_CAUGHT     then show_caught(inning)
        when Inning::DISMISSAL_TYPE_BOWLED     then show_bowled(inning)
        when Inning::DISMISSAL_TYPE_STUMPED    then show_stumped(inning)
        when Inning::DISMISSAL_TYPE_LBW        then show_lbw(inning)
        when Inning::DISMISSAL_TYPE_RUN_OUT    then show_run_out(inning)
        when Inning::DISMISSAL_TYPE_HIT_WICKET then show_hit_wicket(inning)

        when Inning::DISMISSAL_TYPE_RETIRED_HURT,
          Inning::DISMISSAL_TYPE_RETIRED_OUT, 
          Inning::DISMISSAL_TYPE_RETIRED_NOT_OUT, 
          Inning::DISMISSAL_TYPE_RETIRED_ILL then show_retired(inning)

        when Inning::DISMISSAL_TYPE_ABSENT_HURT,
          Inning::DISMISSAL_TYPE_ABSENT_ILL then show_absent(inning)

        when Inning::DISMISSAL_TYPE_HANDLED_THE_BALL then show_handled_the_ball(inning)
        when Inning::DISMISSAL_TYPE_HIT_WICKET       then show_obstructing_the_field(inning)
        else "not out"
      end
    else
      inning.dismissal_text
    end
  end

  def player_link(fielder)
    link = ""
    link += "&dagger;" if fielder.keeper
    link += "sub (" if fielder.substitute
    link += link_to(fielder.player.name, player_path(fielder.player))
    link += ")" if fielder.substitute

    link
  end

  def show_caught(inning)
    fielder = inning.fielders.find_by_involvement(Fielder::FIELDER)
    bowler  = inning.fielders.find_by_involvement(Fielder::BOWLER)

    unless fielder.nil?
      if fielder.player_id == bowler.player_id
        "c & b #{player_link(bowler)}".html_safe
      elsif !fielder.nil?
        "c #{player_link(fielder)} b #{player_link(bowler)}".html_safe
      end
    end
  end

  def show_bowled(inning)
    bowler = inning.fielders.find_by_involvement(Fielder::BOWLER)
    unless bowler.nil?
      "b #{player_link(bowler)}".html_safe
    end
  end

  def show_lbw(inning)
    bowler = inning.fielders.find_by_involvement(Fielder::BOWLER)
    unless bowler.nil?
      "lbw #{player_link(bowler)}".html_safe
    end
  end

  def show_stumped(inning)
    fielder = inning.fielders.find_by_involvement(Fielder::FIELDER)
    bowler  = inning.fielders.find_by_involvement(Fielder::BOWLER)
    logger.info("FIELDER = #{fielder.inspect}")
    logger.info("BOWLER = #{bowler.inspect}")
    if !fielder.nil? && !bowler.nil?
      "st #{player_link(fielder)} b #{player_link(bowler)}".html_safe
    end
  end

  def show_hit_wicket(inning)
    bowler = inning.fielders.find_by_involvement(Fielder::BOWLER)
    unless bowler.nil?
      "hit wicket b #{player_link(bowler)}".html_safe
    end
  end

  def show_run_out(inning)
    fielders = inning.fielders.find_all_by_involvement(Fielder::FIELDER)

    if fielders.empty?
      "run out"
    else
      run_out = fielders.collect { |f| player_link(f) }.join('/')
      "run out (#{run_out})".html_safe
    end
  end

  def show_retired(inning)
    retired = case inning.dismissal_type
      when Inning::DISMISSAL_TYPE_RETIRED_HURT then "hurt"
      when Inning::DISMISSAL_TYPE_RETIRED_OUT then "out"
      when Inning::DISMISSAL_TYPE_RETIRED_NOT_OUT then "not out"
      when Inning::DISMISSAL_TYPE_RETIRED_ILL then "ill"
    end
    "retired #{retired}"
  end

  def show_absent(inning)
    absent = case inning.dismissal_type
      when Inning::DISMISSAL_TYPE_ABSENT_HURT then "hurt"
      when Inning::DISMISSAL_TYPE_ABSENT_ILL then "ill"
    end
    "absent #{absent}"
  end

  def show_handled_the_ball(inning)
    "handled the ball"
  end

  def show_obstructing_the_field(inning)
    "obstructing the field"
  end

end
