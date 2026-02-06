# frozen_string_literal: true

class Backup < ApplicationRecord
  include UserScoped

  validates :filename, presence: true, length: { maximum: 255 }
  validates :size, presence: true, numericality: { greater_than: 0 }
  validates :storage_path, presence: true, length: { maximum: 512 }
  validates :backup_type, presence: true,
            inclusion: { in: %w[automatic manual pre_operation] }

  scope :automatic, -> { where(backup_type: "automatic") }
  scope :manual, -> { where(backup_type: "manual") }
  scope :recent, -> { order(created_at: :desc) }
end
