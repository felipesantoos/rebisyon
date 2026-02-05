# frozen_string_literal: true

class NoteMedium < ApplicationRecord
  # Composite primary key: note_id, media_id
  self.primary_key = [:note_id, :media_id]

  # Associations
  belongs_to :note
  belongs_to :medium

  # Validations
  validates :field_name, length: { maximum: 100 }, allow_nil: true
  validates :note_id, uniqueness: { scope: [:media_id, :field_name] }
end
