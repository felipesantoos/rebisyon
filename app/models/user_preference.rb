# frozen_string_literal: true

class UserPreference < ApplicationRecord
  # Associations
  belongs_to :user

  # Enums
  enum :theme, { light: "light", dark: "dark", auto: "auto" }, prefix: true

  # Validations
  validates :language, presence: true, inclusion: { in: %w[en pt-BR] }
  validates :learn_ahead_limit, numericality: { greater_than_or_equal_to: 0 }
  validates :timebox_time_limit, numericality: { greater_than_or_equal_to: 0 }
  validates :ui_size, numericality: { greater_than: 0, less_than_or_equal_to: 3.0 }
  validates :default_deck_behavior, inclusion: { in: %w[current_deck last_deck_used_to_add first_field] }

  # Scopes
  scope :for_user, ->(user) { where(user_id: user.id) }

  # Returns time of day when the next day starts for study purposes
  # @return [Time] The time when the study day resets
  def day_rollover_time
    next_day_starts_at || Time.zone.parse("04:00:00")
  end
end
