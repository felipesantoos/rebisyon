# frozen_string_literal: true

class Profile < ApplicationRecord
  include SoftDeletable
  include UserScoped

  validates :name, presence: true, length: { maximum: 255 }
  validates :name, uniqueness: { scope: [:user_id, :deleted_at] },
            if: -> { deleted_at.nil? }

  scope :ordered, -> { order(:name) }
  scope :ankiweb_enabled, -> { where(ankiweb_sync_enabled: true) }
end
