# frozen_string_literal: true

Papyrus::Engine.routes.draw do
  namespace :admin do
    resources :templates do
      scope module: :templates do
        resources :attachments
      end
    end
    resources :locales
  end

  namespace :api do
    resources :events
  end

  resource :print_client_license

  resources :print_jobs do
    member do
      post 'resend'
    end
  end

  resources :papers do
    member do
      post 'print'
    end
  end

  resources :templates do
    member do
      get 'paper'
      post 'paper'
    end
  end
  root to: 'dashboard#show'
end
