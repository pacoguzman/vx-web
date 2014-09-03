VxWeb::Application.routes.draw do

  UUID_RE = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/
  SHA_RE = /\b([a-f0-9]{40})\b/

  namespace :api, constraints: { id: UUID_RE } do
    resources :invites, only: [:create]

    resources :users, only: [:index, :update, :destroy] do
      collection do
        get :me
      end
    end

    namespace :user_identities do
      resources :gitlab, only: [:update, :create, :destroy]
    end

    resources :projects do
      member do
        get "key.:format", action: :key, as: 'public_key'
        get :branches
        post :rebuild
      end

      resources :builds, only: [:index, :create]
      resources :cached_files, only: [:index] do
        collection do
          post :mass_destroy
        end
      end
      resource :subscription, only: [:create, :destroy], controller: "project_subscriptions"

      resources :pull_requests, only: [:index]
      resources :builds_branches, only: [:index]
    end

    resources :builds, only: [:show] do
      member do
        post :restart
        get :status_for_gitlab, constraints: { id: SHA_RE }
      end
      collection do
        get :queued
      end
      resources :jobs, only: [:index]
    end

    resources :jobs, only: [:show] do
      resources :logs, only: [:index], controller: "job_logs"
    end

    resources :user_repos, only: [:index] do
      member do
        post :subscribe
        post :unsubscribe
      end
      collection do
        post :sync
      end
    end

    resources :companies, only: [] do
      get :usage, on: :collection
      member do
        post :default
      end
    end

    resources :invoices, only: [:index]
  end

  namespace :users do
    get 'github/callback', to: "github#callback"
    get 'failure',         to: redirect('/ui')
    get '/:id/become',     to: 'session#become'

    resource :session, only: [:destroy, :show], controller: "session"
    resource :invite,  only: [:new]
    resource :signup,  only: [:show, :new, :create], controller: "signup"

    scope "/projects/:project_id" do
      get "/unsubscribe/:id", to: "project_subscriptions#unsubscribe",
        constraints: { project_id: UUID_RE, id: UUID_RE },
        as: "unsubscribe_user_from_project"
    end
  end

  put "/f/cached_files/:token/*file_name.:file_ext", to: "api/cached_files#upload", as: :upload_cached_file
  get "/f/cached_files/:token/*file_name.:file_ext", to: "api/cached_files#download"

  post '/callbacks/:_service/:_token', to: 'repo_callbacks#create', _service: /(github|gitlab)/,
    as: 'repo_callback'

  scope constraints: ->(req){ req.format == Mime::HTML } do
    get "/",         to: redirect("/ui")
    get "/ui",       to: "users/session#show"
    get "/ui/*path", to: "users/session#show"
  end
end
