Rails.application.routes.draw do
  root to: "toppages#index"
  
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'
  resource :users, only: [:edit, :update, :destroy] do
    member do
      get :password_edit
      patch :password_update
      get :search
      get :favorite_recipes
      get :friends
    end
  end
  resources :users, only: [:show]
  get 'users', to: 'users#render_edit'
  get 'users/password_update', to: 'users#render_password_edit'

  resource :relationships, only: [:create, :update, :destroy]
  resource :bookmarks, only: [:create, :destroy]
  resource :meals, only: [:index, :show]
  resource :menus, only: [:create, :destroy]
  
  resource :recipes, only: [:new, :create] do
    collection do
      post :easy_create
      get :sort
      get :keyword_search
      get :feature_search
    end
  end
  resources :recipes, only: [:show,  :edit, :update, :destroy] do
    member do
      patch :easy_update
      patch :size_update
      patch :publish
      patch :stop_publish
    end
    resource :ingredients, :steps, only: [:edit, :update]
  end
  get 'recipes/:id/easy_update', to: 'recipes#redirect_show'
  get 'recipes', to: 'recipes#redirect_new'
  get 'recipes/easy_create', to: 'recipes#redirect_new'
  get 'recipes/:id/ingredients', to: 'ingredients#redirect_edit'
end
