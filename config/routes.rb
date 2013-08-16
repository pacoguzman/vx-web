CiWeb::Application.routes.draw do

  namespace :api do

    resources :projects do
      resources :builds, only: [:index, :create]
    end

    resources :builds, only: [:show] do
      resources :jobs, only: [:index]
    end

    resources :jobs, only: [:show]

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

  resources :events, only: [:index]

  get '/github/callback/:token', to: 'github/repo_callbacks#create'

  get '/auth/github/callback', to: 'github/user_callbacks#create'
  get '/auth/failure', to: redirect('/')

  root 'welcome#index'

  get "*path", to: "welcome#index", constraints: ->(req) { req.format == Mime::HTML }
end
