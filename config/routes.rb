Rails.application.routes.draw do
  # Devise authentication for web
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    confirmations: "users/confirmations"
  }

  # API namespace with JWT authentication
  namespace :api do
    namespace :v1 do
      # JWT Auth endpoints
      devise_scope :user do
        post "auth/sign_in", to: "sessions#create"
        delete "auth/sign_out", to: "sessions#destroy"
        post "auth/sign_up", to: "registrations#create"
      end

      # Core data
      resources :decks, only: %i[index show create update destroy]
      resources :note_types, only: %i[index show create update destroy]
      resources :notes, only: %i[index show create update destroy]
      resources :cards, only: %i[index show update]
      resources :reviews, only: %i[index show]
      resources :media, only: %i[index show create destroy]

      # Configuration
      resource :user_preferences, only: %i[show update]
      resources :filtered_decks, only: %i[index show create update destroy]
      resources :backups, only: %i[index show create destroy]
      resources :deck_options_presets, only: %i[index show create update destroy]
      resources :saved_searches, only: %i[index create update destroy]
      resources :flag_names, only: %i[index create update destroy]
      resource :browser_config, only: %i[show update]
      resources :add_ons, only: %i[index show create update destroy]
      resources :profiles, only: %i[index show create update destroy]

      # Sync and audit
      resources :sync_meta, only: %i[index show create update destroy]
      resources :undo_histories, only: :index
      resources :deletion_logs, only: :index
      resources :check_database_logs, only: %i[index show]

      # Sharing
      resources :shared_decks, only: %i[index show create update destroy] do
        resources :ratings, only: %i[index create update destroy],
                  controller: "shared_deck_ratings"
      end
    end
  end

  # Mission Control for Solid Queue jobs (admin interface)
  authenticate :user, ->(user) { user.email.end_with?("@rebisyon.com") } do
    mount MissionControl::Jobs::Engine, at: "/mission_control"
  end

  # Web application routes
  root "dashboard#show"

  # Dashboard
  resource :dashboard, only: :show, controller: "dashboard"

  # User preferences
  resource :user_preferences, only: %i[edit update], path: "preferences"

  # Decks (to be expanded in Phase 2)
  resources :decks do
    # Study sessions nested under decks
    resource :study_session, only: :show, path: "study" do
      post :answer
      post :show_answer
      post :undo
      get :congrats
    end
  end

  # Cards
  resources :cards, only: %i[show edit update] do
    collection do
      post :bulk_flag
      post :bulk_suspend
      post :bulk_bury
      post :bulk_reset_scheduling
      post :bulk_set_due_date
    end
  end

  # Notes & Browser (to be expanded in Phase 3)
  resources :notes
  resources :note_types

  # Deck options presets
  resources :deck_options_presets

  # Saved searches
  resources :saved_searches, except: :show

  # Flag names
  resources :flag_names, only: %i[index create update destroy]

  # Browser config (singular)
  resource :browser_config, only: %i[show update]

  # Import/Export
  resources :imports, only: %i[new create]
  resources :exports, only: %i[new create]

  # Media management
  resources :media, only: %i[index show create destroy] do
    collection do
      post :check
    end
  end

  # Check database
  resources :check_database_logs, only: %i[index show], path: "check-database"

  # Backups
  resources :backups, only: %i[index show create destroy]

  # Profiles
  resources :profiles

  # Filtered decks
  resources :filtered_decks

  # Add-ons
  resources :add_ons, only: %i[index show create update destroy], path: "add-ons"

  # Shared decks
  resources :shared_decks do
    resources :ratings, only: %i[create update destroy], controller: "shared_deck_ratings"
  end

  # Deletion logs (trash)
  resources :deletion_logs, only: %i[index show], path: "trash" do
    member do
      post :restore
    end
  end

  # Undo history
  resources :undo_histories, only: %i[index show], path: "undo-history"

  # Reviews
  resources :reviews, only: [:index]

  # Sync status
  resources :sync_metas, only: %i[index], path: "sync"

  # Statistics (to be expanded in Phase 5)
  resource :statistics, only: :show

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA files
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
