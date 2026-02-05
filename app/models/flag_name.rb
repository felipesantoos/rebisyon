# frozen_string_literal: true

class FlagName < ApplicationRecord
  include UserScoped

  # Validations
  validates :flag_number, presence: true, inclusion: { in: 1..7 }
  validates :name, presence: true, length: { maximum: 50 }
  validates :flag_number, uniqueness: { scope: :user_id }

  # Scopes
  scope :for_flag, ->(number) { where(flag_number: number) }
end
