# frozen_string_literal: true

class SavedSearch < ApplicationRecord
  include SoftDeletable
  include UserScoped

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :search_query, presence: true
  validates :name, uniqueness: { scope: [:user_id, :deleted_at] }, if: -> { deleted_at.nil? }

  # Scopes
  scope :ordered, -> { order(:name) }
end
