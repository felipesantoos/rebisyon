# frozen_string_literal: true

class CheckDatabaseLog < ApplicationRecord
  self.table_name = "check_database_log"

  include UserScoped

  STATUSES = %w[running completed failed corrupted].freeze

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :issues_found, presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  scope :recent, -> { order(created_at: :desc) }
  scope :with_issues, -> { where("issues_found > 0") }
end
