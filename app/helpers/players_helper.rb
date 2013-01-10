module PlayersHelper

  def victim_count(type, innings)
    bowlers = fielders = {}
    innings.each do |inning|
      if bowler = inning.fielders.find_by_involvement(Fielder::BOWLER)
        bowlers[bowler.player_id]   ||= 0
        bowlers[bowler.player_id]   += 1
      end

      if fielder = inning.fielders.find_by_involvement(Fielder::FIELDER)
        fielders[fielder.player_id] ||= 0
        fielders[fielder.player_id] += 1
      end
    end

    case type
      when 'bowler' then bowlers.sort_by { |k,v| v }.last
      when 'fielder' then fielders.sort_by { |k,v| v }.last
      else {}
    end
  end

end
