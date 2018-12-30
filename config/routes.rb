Rails.application.routes.draw do
  get '/users/new' => 'users#new'
  post '/users/create' => 'users#create'
  get '/users/:id/dashboard' => 'pages#dashboard'
  get '/users/:id/images/new' => 'user_images#new', as: :add_image
  post '/user_images/create' => 'user_images#create'
  root 'pages#login'
  resources :users
  resources :user_images
end
