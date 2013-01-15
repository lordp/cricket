class NewsController < ApplicationController
  def index
    @news = News.order('created_at desc').all
  end
end
