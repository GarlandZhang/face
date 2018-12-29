Rails.application.routes.draw do
  get '/users/new' => 'users#new'
  post '/users/create' => 'users#create'
  get '/users/:id/dashboard' => 'pages#dashboard'
  get '/images/new' => 'user_images#new', as: :user_images
  post '/images/create' => 'user_images#create'
  root 'pages#login'
  resources :users
  resources :user_images
end
