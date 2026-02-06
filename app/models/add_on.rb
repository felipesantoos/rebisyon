# frozen_string_literal: true

class AddOn < ApplicationRecord
  include UserScoped

  validates :code, presence: true, length: { maximum: 50 }
  validates :code, uniqueness: { scope: :user_id }
  validates :name, presence: true, length: { maximum: 255 }
  validates :version, presence: true, length: { maximum: 20 }

  scope :enabled, -> { where(enabled: true) }
  scope :disabled, -> { where(enabled: false) }
end
