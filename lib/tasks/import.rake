namespace :import do

  desc "Import matches"
  task :matches => :environment do

    innings_count = ENV["INNINGS_COUNT"] || 4
    match_type = ENV["MATCH_TYPE"] || 0

    innings_count = innings_count.to_i

    headings = {
      'R'  => 'runs',
      'M'  => 'minutes',
      'B'  => 'balls',
      '4s' => 'fours',
      '6s' => 'sixes',
    }

    matches = Naturalsorter::Sorter.sort(Dir.glob("#{Rails.root}/tmp/*.html"), 'caseinsensitive')
    matches.each do |file|

      doc = Nokogiri::HTML(open(file))

      teams = doc.css('a.teamLink').collect(&:text)
      match_number, season, ground = doc.css('div.headRightDiv a.headLink').collect(&:text)
      series = doc.css('div.headLeftDiv a.headLink').collect(&:text).first.strip
      match_dates = doc.css('div.headRightDiv li:last').collect(&:text).first.strip

      match_id = file.split('/').last
      puts "(#{match_id}) #{match_number} at #{ground}, #{series}"

      match_number.gsub!(/[^0-9]+/, '')

      match = Match.find_or_create_by_match_number_and_match_type(match_number, match_type)
      match.team1        = Team.find_or_create_by_name(teams[0].strip)
      match.team2        = Team.find_or_create_by_name(teams[1].strip)
      match.match_type   = match_type
      match.match_number = match_number
      match.season       = season.strip
      match.ground       = Ground.find_or_create_by_name(ground.strip)
      match.series       = series.strip
      match.match_dates  = match_dates
      match.cricinfo_id  = match_id

      match.save!

      batting_inning_team = bowling_inning_team = []

      (1..innings_count).each do |i|
        if doc.css("table#inningsBat#{i}").count > 0
          header = doc.css("table#inningsBat#{i} tr.inningsHead td").collect(&:text)
          header_loc = {}
          header.each_with_index { |h, idx| header_loc[headings[h]] = (idx + 1) * 2 unless headings[h].nil? }

          batting_inning_team[i] = get_team(match, header[1].strip)

          doc.css("table#inningsBat#{i} tr.inningsRow").each do |p|
            cricinfo_id = nil
            name        = nil
            captain     = false
            keeper      = false

            if !p.children[2].css('a').empty?
              cricinfo_id, name, full_name = p.children[2].css('a').collect { |a| [ a['href'].match(/([\d]+)/)[1], a.text, a['title'].gsub(/view the player profile for /, '') ] }.first
              captain = true if p.children[2].text.match(/\*/)
              keeper  = true if p.children[2].text.match(/\u2020/)
            elsif p.children[2].text == 'Extras'
              cricinfo_id, name = [0, 'Extras']
            end

            unless cricinfo_id.nil?
              if player = Player.find_or_create_by_cricinfo_id(cricinfo_id)
                player.update_attribute(:name, name) if player.name.nil?
                player.update_attribute(:full_name, full_name) if player.full_name.nil?
                if inning = Inning.find_or_create_by_inning_number_and_match_id_and_player_id(:inning_number => i, :match_id => match.id, :player_id => player.id)
                  inning.inning_type    = Inning::INNING_TYPE_BAT
                  inning.dismissal_text = check_field(p.children[4])
                  inning.team           = batting_inning_team[i]
                  inning.captain        = captain
                  inning.keeper         = keeper

                  header_loc.each do |k, v|
                    inning.send("#{k}=", check_field(p.children[v]))
                  end

                  inning.save!
                end
              end
            end
          end
        end

        if doc.css("table#inningsBowl#{i}").count > 0
          bowling_inning_team[i] = get_other_team(match, batting_inning_team[i])
          doc.css("table#inningsBowl#{i} tr.inningsRow").each do |p|
            cricinfo_id, name, full_name = p.children[2].css('a').collect { |a| [ a['href'].match(/([\d]+)/)[1], a.text, a['title'].gsub(/view the player profile for /, '') ] }.first
            if player = Player.find_or_create_by_cricinfo_id(cricinfo_id)
              player.update_attribute(:name, name) if player.name.nil?
              player.update_attribute(:full_name, full_name) if player.full_name.nil?
              if inning = Inning.find_or_create_by_inning_number_and_match_id_and_player_id(:inning_number => i, :match_id => match.id, :player_id => player.id)
                inning.inning_type    = Inning::INNING_TYPE_BOWL
                inning.overs          = check_field(p.children[4])
                inning.maidens        = check_field(p.children[6])
                inning.runs           = check_field(p.children[8])
                inning.wickets        = check_field(p.children[10])
                inning.extras         = check_field(p.children[14])
                inning.team           = bowling_inning_team[i]
                inning.save!
              end
            end
          end
        end
      end

      doc.css("table.inningsTable").each do |table|
        if !table['id'].nil?
          current_inning = table['id'].match(/inningsBat([\d]+)/).captures.first.to_i unless table['id'].match(/inningsBat([\d]+)/).nil?
        end

        if !current_inning.nil? && current_inning > 0
          if table.css('b').text == 'Did not bat'
            table.css('a').each do |a|
              player = Player.find_or_create_by_cricinfo_id(a['href'].match(/([\d]+)/).captures.first)
              player.update_attribute(:name, a.text) if player.name.blank?
              player.update_attribute(:full_name, a['title'].gsub(/view the player profile for /, '')) if player.full_name.nil?

              inning = Inning.find_or_create_by_player_id_and_match_id_and_inning_number_and_inning_type(:player_id => player.id, :match_id => match.id, :inning_number => current_inning, :inning_type => Inning::INNING_TYPE_BAT)
              inning.save!
            end
          end
        end
      end

    end
  end

  private

    def check_field(field)
      return field.nil? ? nil : field.text.strip
    end

    def get_team(match, name)
      return match.team1 if name.match(/#{match.team1.name} /)
      return match.team2 if name.match(/#{match.team2.name} /)
    end

    def get_other_team(match, batting_team)
      return match.team2 if batting_team.name == match.team1.name
      return match.team1 if batting_team.name == match.team2.name
    end

end
