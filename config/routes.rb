Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/users/new' => 'users#new'
  post '/users/create' => 'users#create'
  get '/users/:id/dashboard' => 'pages#dashboard', as: :dashboard
  get '/users/:id/images/new' => 'user_images#new', as: :add_image
  post '/user_images/create' => 'user_images#create'
  get '/people/:id/show' => 'people#show', as: :person
  get '/people/:id/edit' => 'people#edit', as: :edit_person
  get '/user_images/search' => 'user_images#search', as: :search
  patch '/people/:id/update' => 'people#update', as: :update_person
  get '/user_images/:id/show' => 'user_images#show', as: :show_image
  root 'pages#login'
  resources :users
  resources :user_images
  resources :people
end
