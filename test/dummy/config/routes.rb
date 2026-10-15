Rails.application.routes.draw do
  mount Mensa::Engine => '/mensa'
  mount Papyrus::Engine => '/papyrus'
end
