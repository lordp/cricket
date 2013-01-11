namespace :update do

  desc "Update players"
  task :players => :environment do

    player_list = open("#{Rails.root}/players.txt").read

    player_list.split(/\n/).each do |player|

      p = Nokogiri::HTML(player)
      name = p.css('a').first.text
      cricinfo_id = p.css('a').first['href'].match(/\/ci\/content\/player\/([\d]+)\.html/)[1]

      puts "#{name} => #{cricinfo_id}"

      Player.where(:name => name).first.update_attribute(:cricinfo_id, cricinfo_id)

    end
  end

  desc "Update matches"
  task :matches => :environment do

    match_list = open("#{Rails.root}/odi.txt").read

    match_list.split(/\n/).each do |match|

      cricinfo_id, match_number = match.split(/,/)
      puts "#{match_number} => #{cricinfo_id}"

      Match.where(:match_number => match_number).where(:match_type => 1).first.update_attribute(:cricinfo_id, cricinfo_id)

    end
  end

  desc "Update innings"
  task :innings => :environment do
    dnb_innings = Inning.joins(:match).group('matches.cricinfo_id').group(:inning_number).order('matches.cricinfo_id', :inning_number).where(:inning_type => Inning::INNING_TYPE_BAT).where('player_id != ?', 12).where('matches.match_type = ?', Match::MATCH_TYPE_TEST).count.find_all { |i| i[1] < 11 }.collect { |i| i[0][0] }

    dnb_innings.each do |dnb|
      match_inning, count = dnb
      match_cricinfo_id, inning_number = match_inning

      match = Match.find_by_cricinfo_id(match_cricinfo_id)
      doc = Nokogiri::HTML(open("public/tests/#{match_cricinfo_id}.html"))
      puts "Match: ##{match.cricinfo_id}"

      current_inning = 0
      doc.css("table.inningsTable").each do |table|
        if !table['id'].nil?
          current_inning = table['id'].match(/inningsBat([\d]+)/).captures.first.to_i unless table['id'].match(/inningsBat([\d]+)/).nil?
        elsif current_inning > 0
          if table.css('b').text == 'Did not bat'
            table.css('a').each do |a|
              player = Player.find_or_create_by_cricinfo_id(a['href'].match(/([\d]+)/).captures.first)
              player.update_attribute(:name, a.text) if player.name.blank?

              inning = Inning.find_or_create_by_player_id_and_match_id_and_inning_number_and_inning_type(:player_id => player.id, :match_id => match.id, :inning_number => current_inning, :inning_type => 0)
              puts "- #{inning.player.name}"
            end
          end
        end
      end
    end
  end

  desc "Update match dates"
  task :match_dates => :environment do
    Match.all.each do |match|
      begin
        #<MatchData "31 December 1910, 2,3,4 January 1911" 1:"31" 2:"" 3:nil 4:" " 5:"December" 6:" 1910" 
        #7:", 2,3,4 January 1911" 8:"2" 9:",3,4" 10:",4" 11:" " 12:"January" 13:"1911" 14:nil>

        #<MatchData "29,30 January, 1,2,3 February 1892" 1:"29" 2:",30" 3:",30" 4:" " 5:"January" 6:nil
        #7:", 1,2,3 February 1892" 8:"1" 9:",2,3" 10:",3" 11:" " 12:"February" 13:"1892" 14:nil>

        #<MatchData "29,30 January 1892" 1:"29" 2:",30" 3:",30" 4:" " 5:"January" 6:nil
        #7:" 1892" 8:nil 9:nil 10:nil 11:nil 12:nil 13:nil 14:"1892">

        #<MatchData "29,30 November, 1,3,4 December 1974" 1:"29" 2:",30" 3:",30" 4:" " 5:"November" 6:nil
        #7:", 1,3,4 December 1974" 8:"1" 9:",3,4" 10:",4" 11:" " 12:"December" 13:"1974" 14:nil>

        match_date_regex = match.match_dates.match(/(\d+)((,[ ]?\d+)*)(,?[ ]+)([A-Za-z]+)( \d+)?(, (\d+)((,\d+)*)(,?[ ]+)([A-Za-z]+)[ ]+(\d+)|[ ]+(\d+))/)
        if match_date_regex[14].nil?
          if match_date_regex[6].nil?
            start_date = Date.parse("#{match_date_regex[1]} #{match_date_regex[5]} #{match_date_regex[13]}")
            if match_date_regex[10].nil?
              end_date = Date.parse("#{match_date_regex[8].gsub(/[^\d]/, '').to_i} #{match_date_regex[12]} #{match_date_regex[13]}")
            else
              end_date = Date.parse("#{match_date_regex[10].gsub(/[^\d]/, '').to_i} #{match_date_regex[12]} #{match_date_regex[13]}")
            end
          else
            start_date = Date.parse("#{match_date_regex[1]} #{match_date_regex[5]} #{match_date_regex[6]}")
            if match_date_regex[10].nil?
              end_date = Date.parse("#{match_date_regex[8].gsub(/[^\d]/, '').to_i} #{match_date_regex[12]} #{match_date_regex[13]}")
            else
              end_date = Date.parse("#{match_date_regex[10].gsub(/[^\d]/, '').to_i} #{match_date_regex[12]} #{match_date_regex[13]}")
            end
          end
        else
          start_date = Date.parse("#{match_date_regex[1]} #{match_date_regex[5]} #{match_date_regex[14]}")
          end_date   = Date.parse("#{match_date_regex[3].gsub(/[^\d]/, '').to_i} #{match_date_regex[5]} #{match_date_regex[14]}")
        end

        puts "#{match.match_number} - #{start_date} to #{end_date}"
        match.update_attributes({ :start_date => start_date, :end_date => end_date })
      rescue Exception => e
        puts match.id
        puts match.match_dates
        puts e

        puts start_date
        puts end_date

        puts match_date_regex.inspect
        #exit
      end
    end
  end

  desc "Update matches to link to teams"
  task :match_teams => :environment do
    Match.all.each do |match|
      match.teams << Team.find_or_create_by_name(match.team1_name)
      match.teams << Team.find_or_create_by_name(match.team2_name)

      match.save
    end
  end

  desc "Create grounds"
  task :grounds => :environment do
    Match.all.each do |match|
      match.ground = Ground.find_or_create_by_name(match.read_attribute(:ground))
      match.save
    end
  end
end
