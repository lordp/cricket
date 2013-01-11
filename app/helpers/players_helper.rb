module PlayersHelper

  def antagonist_count(antagonists)
    links = ''
    antagonists.each do |antagonist|
      player = Player.find(antagonist[0])
      links += content_tag('li', link_to("#{player.name} (#{pluralize(antagonist[1], 'time')})", player), {}, false)
    end

    content_tag('ol', links, {}, false)
  end
end
