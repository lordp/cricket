module ApplicationHelper
  def active_page?(page)
    "active" if page == params[:controller]
  end

  def cricinfo_link(object)
    case object
      when Match then link_to('CricInfo page', "http://www.espncricinfo.com/ci/engine/match/#{object.cricinfo_id}.html")
      when Inning then link_to('CricInfo page', "http://www.espncricinfo.com/ci/engine/match/#{object.match.cricinfo_id}.html")
      when Player then link_to('CricInfo page', "http://www.espncricinfo.com/ci/content/player/#{object.cricinfo_id}.html")
      else 'hello'
    end
  end
end
