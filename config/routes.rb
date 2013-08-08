CiWeb::Application.routes.draw do

  namespace :api do
    resources :projects
    resources :github_repos, only: [:index] do
      member do
        post :subscribe
        post :unsubscribe
      end
      collection do
        post :sync
      end
    end
  end

  get '/auth/github/callback', to: 'github/users_callbacks#create'
  get '/auth/failure', to: redirect('/')

  root 'welcome#index'

  get "*path", to: "welcome#index", constraints: ->(req) { req.format == Mime::HTML }
end
