VxWeb::Application.routes.draw do

  namespace :api do

    resources :users do
      collection do
        get :me
      end
    end

    resources :projects do
      resources :builds, only: [:index, :create]
      resources :cached_files, only: [:index]
      resource :subscription, only: [:create, :destroy], controller: "project_subscriptions"
      member do
        get "key"
      end
    end

    resources :builds, only: [:show] do
      member do
        post :restart
      end
      resources :jobs, only: [:index]
    end

    resources :jobs, only: [:show] do
      resources :logs, only: [:index], controller: "job_logs"
    end

    resources :cached_files, only: [:destroy]

    resources :user_repos, only: [:index] do
      member do
        post :subscribe
        post :unsubscribe
      end
      collection do
        post :sync
      end
    end
  end

  get  'auth/github/callback', to: 'github/user_sessions#create'
  post 'auth/gitlab/session',  to: "gitlab/user_sessions#create"
  get  'auth/failure',         to: redirect('/')

  put "cached_files/u/:token/*file_name.:file_ext", to: "api/cached_files#upload"
  get "cached_files/u/:token/*file_name.:file_ext", to: "api/cached_files#download"

  # TODO: remove it
  post '/callbacks/:_service/:_token', to: 'repo_callbacks#create', _service: /(github|gitlab)/,
    as: 'repo_callback'

  get '/events', to: 'events#index'

  post '/build', to: 'welcome#index'

  root 'welcome#index'

  get "*path", to: "welcome#index", constraints: ->(req) { req.format == Mime::HTML }
end
