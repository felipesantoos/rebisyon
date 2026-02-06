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

      # API resources (to be expanded)
      resources :decks, only: %i[index show create update destroy]
      resources :note_types, only: %i[index show create update destroy]
      resources :notes, only: %i[index show create update destroy]
      resource :user_preferences, only: %i[show update]
      resource :profile, only: %i[show update]
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

  # Media management
  resources :media, only: %i[index show create destroy]

  # Statistics (to be expanded in Phase 5)
  resource :statistics, only: :show

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA files
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
