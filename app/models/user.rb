# frozen_string_literal: true

class User < ApplicationRecord
  include SoftDeletable
  include Devise::JWT::RevocationStrategies::Denylist

  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  # Associations
  has_one :user_preference, dependent: :destroy
  has_many :decks, dependent: :destroy
  has_many :note_types, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :media, dependent: :destroy
  has_many :backups, dependent: :destroy
  has_many :filtered_decks, dependent: :destroy
  has_many :deck_options_presets, dependent: :destroy
  has_many :deletions_logs, dependent: :destroy
  has_many :saved_searches, dependent: :destroy
  has_many :flag_names, dependent: :destroy
  has_one :browser_config, dependent: :destroy
  has_many :undo_histories, dependent: :destroy
  has_many :shared_decks, foreign_key: :author_id, dependent: :destroy
  has_many :shared_deck_ratings, dependent: :destroy
  has_many :add_ons, dependent: :destroy
  has_many :check_database_logs, dependent: :destroy
  has_many :profiles, dependent: :destroy
  has_many :sync_metas, dependent: :destroy
  has_many :cards, through: :notes

  # Callbacks
  after_create :setup_defaults

  # Updates last_login_at timestamp
  def track_login!
    update_column(:last_login_at, Time.current)
  end

  # Returns the user's preference, creating it if it doesn't exist
  def preference
    user_preference || create_user_preference!
  end

  private

  # Sets up default configuration for new users
  def setup_defaults
    Users::SetupService.new(self).call
  end
end
