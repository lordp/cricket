module PlayersHelper

  def cricinfo_link(player)
    link_to('CricInfo page', "http://www.espncricinfo.com/ci/content/player/#{player.cricinfo_id}.html")
  end

end
