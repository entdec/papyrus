# frozen_string_literal: true

Papyrus::Engine.routes.draw do
  namespace :admin do
    resources :templates
    resources :locales
  end
  resources :templates do
    member do
      get 'paper'
      post 'paper'
    end
  end
  root to: 'dashboard#show'
end
