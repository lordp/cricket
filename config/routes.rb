Cricinfo::Application.routes.draw do
  resources :matches, :grounds, :series, :seasons

  resources :players do
    member do
      get 'chart'
      get 'batting_innings'
      get 'bowling_innings'
    end
  end

  resources :teams do
    resources :players, :matches
  end

  match 'players/search/:term' => 'players#search', :via => :get

  root :to => 'news#index'
end
