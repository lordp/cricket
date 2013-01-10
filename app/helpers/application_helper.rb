module ApplicationHelper
  def active_page?(page)
    "active" if page == params[:controller]
  end
end
