# frozen_string_literal: true

class Card < ApplicationRecord
  # Associations
  belongs_to :note
  belongs_to :deck
  belongs_to :home_deck, class_name: "Deck", optional: true
  has_many :reviews, dependent: :destroy

  # Enums
  # Using _prefix: true to avoid conflict with ActiveRecord's new? method
  # PostgreSQL enum type card_state stores string values
  enum :state, { new: "new", learn: "learn", review: "review", relearn: "relearn" }, prefix: true

  # Validations
  validates :card_type_id, presence: true
  validates :due, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :interval, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :ease, presence: true, numericality: { greater_than_or_equal_to: 1300 }
  validates :lapses, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :reps, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :flag, presence: true, inclusion: { in: 0..7 }
  validates :state, presence: true

  # Custom validations
  validate :home_deck_different_from_deck
  validate :review_state_has_valid_interval
  validate :review_state_has_valid_due
  validate :new_state_has_valid_position

  # Scopes
  scope :active, -> { where(suspended: false, buried: false) }
  scope :due_for_review, ->(timestamp) { where("due <= ?", timestamp).where(state: :review) }
  scope :due_for_learning, ->(timestamp) { where("due <= ?", timestamp).where(state: [:learn, :relearn]) }
  scope :new_cards, -> { where(state: :new) }
  scope :siblings_of, ->(card) { where(note_id: card.note_id).where.not(id: card.id) }

  # Checks if this card is a leech (has too many lapses)
  # @param threshold [Integer] Number of lapses to consider a leech (default: 8)
  # @return [Boolean]
  def leech?(threshold = 8)
    lapses >= threshold
  end

  private

  def home_deck_different_from_deck
    return unless home_deck_id.present? && home_deck_id == deck_id

    errors.add(:home_deck_id, "must be different from deck_id")
  end

  def review_state_has_valid_interval
    return unless state == "review"

    errors.add(:interval, "must be >= 0 for review state") if interval < 0
  end

  def review_state_has_valid_due
    return unless state == "review"

    # Due must be a timestamp (milliseconds since epoch) > 1000000000000
    errors.add(:due, "must be a valid timestamp for review state") if due <= 1_000_000_000_000
  end

  def new_state_has_valid_position
    return unless state == "new"

    errors.add(:position, "must be >= 0 for new state") if position < 0
  end
end
