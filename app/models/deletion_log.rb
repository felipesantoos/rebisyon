# frozen_string_literal: true

class DeletionLog < ApplicationRecord
  self.table_name = "deletions_log"

  include UserScoped

  # Validations
  validates :object_type, presence: true, inclusion: { in: %w[note card deck note_type] }
  validates :object_id, presence: true
  validates :deleted_at, presence: true

  # JSONB accessor for object_data
  store_accessor :object_data
end
