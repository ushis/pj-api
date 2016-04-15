Rails.application.routes.draw do
  match '*path', controller: :application, action: :options, via: :options

  namespace :v1 do
    resource  :profile,        only: [:show, :create, :update, :destroy]
    resource  :password_reset, only: [:create, :update]
    resources :sessions,       only: [:create]
    resources :users,          only: [:index, :show]
    resources :replies,        only: [:create]

    resources :cars, only: [:index, :show, :create, :update, :destroy] do
      resource  :location,      only: [:show, :create, :update, :destroy]
      resources :comments,      only: [:index, :show, :create, :update, :destroy]
      resources :ownerships,    only: [:index, :show, :create, :destroy]
      resources :borrowerships, only: [:index, :show, :create, :destroy]

      resources :rides, only: [:index, :show, :create, :update, :destroy] do
        resources :comments, only: [:index, :show, :create, :update, :destroy]
      end

      resources :reservations, only: [:index, :show, :create, :update, :destroy] do
        resources :comments, only: [:index, :show, :create, :update, :destroy]
      end
    end
  end
end
