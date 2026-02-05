# frozen_string_literal: true

class Review < ApplicationRecord
  # Associations
  belongs_to :card

  # Enums
  # Note: Using 'review_type' as column name to avoid conflict with Rails' reserved 'type' column
  # PostgreSQL enum types store strings, not integers, so we use string values directly
  enum review_type: {
    learn: 'learn',
    review: 'review',
    relearn: 'relearn',
    cram: 'cram'
  }

  # Validations
  validates :rating, presence: true, inclusion: { in: 1..4 }
  validates :interval, presence: true, numericality: { other_than: 0 }
  validates :ease, presence: true
  validates :time_ms, presence: true, numericality: { greater_than: 0 }
  validates :review_type, presence: true
end
