Rails.application.routes.draw do
  get '/users/new' => 'users#new'
  post '/users/create' => 'users#create'
  get '/users/:id/dashboard' => 'pages#dashboard'
  get '/users/:id/images/new' => 'user_images#new', as: :add_image
  post '/user_images/create' => 'user_images#create'
  get '/people/:id/show' => 'people#show', as: :person
  root 'pages#login'
  resources :users
  resources :user_images
  resources :people
end
