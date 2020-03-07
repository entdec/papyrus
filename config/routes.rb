# frozen_string_literal: true

Papyrus::Engine.routes.draw do
  resource :templates do
    member do
      get 'paper'
    end
  end
end
