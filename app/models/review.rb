# frozen_string_literal: true

class Review < ApplicationRecord
  self.inheritance_column = :_type_disabled

  # Associations
  belongs_to :card

  # Enums
  enum :type, { learn: "learn", review: "review", relearn: "relearn", cram: "cram" }, prefix: true

  # Validations
  validates :rating, presence: true, inclusion: { in: 1..4 }
  validates :interval, presence: true, numericality: { other_than: 0 }
  validates :ease, presence: true
  validates :time_ms, presence: true, numericality: { greater_than: 0 }
  validates :type, presence: true
end
