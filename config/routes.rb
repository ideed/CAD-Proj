Rails.application.routes.draw do
  devise_for :users
  resources :posts do
    member do
      get "like" => "posts#upvote"
      get "unlike" => "posts#downvote"
    end
    resources :comments
  end
  root to: 'posts#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
