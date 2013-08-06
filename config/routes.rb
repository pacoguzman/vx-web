CiWeb::Application.routes.draw do

  get '/auth/github/callback', to: 'github/users_callbacks#create'
  get '/auth/failure', to: redirect('/')

  namespace :api do
    resources :projects
  end

  root 'welcome#index'
end
