VxWeb::Application.routes.draw do

  namespace :api do

    resources :users do
      collection do
        get :me
      end
    end

    resources :projects do
      resources :builds, only: [:index, :create]
      resource :subscription, only: [:create, :destroy], controller: "project_subscriptions"
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

    resources :github_repos, only: [:index] do
      member do
        post :subscribe
        post :unsubscribe
      end
      collection do
        post :sync
      end
    end

    put "cached_files/upload/:token/*file_name.:file_ext", to: "cached_files#upload"
  end

  post '/github/callback/:token', to: 'github/repo_callbacks#create'

  get '/auth/github/callback', to: 'github/user_callbacks#create'
  get '/auth/failure', to: redirect('/')

  get '/sse_events', to: 'sse_events#index'

  root 'welcome#index'

  get "*path", to: "welcome#index", constraints: ->(req) { req.format == Mime::HTML }
end
