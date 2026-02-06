# frozen_string_literal: true

class DeckOptionsPreset < ApplicationRecord
  include SoftDeletable
  include UserScoped

  # Associations
  # Deck association will be added when options_preset_id is added to decks table
  # has_many :decks, foreign_key: :options_preset_id, dependent: :nullify

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :name, uniqueness: { scope: [:user_id, :deleted_at] }, if: -> { deleted_at.nil? }

  # Scopes
  scope :ordered, -> { order(:name) }
end
