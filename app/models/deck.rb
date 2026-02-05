# frozen_string_literal: true

class Deck < ApplicationRecord
  include SoftDeletable
  include UserScoped

  # Associations
  belongs_to :parent, class_name: "Deck", optional: true
  has_many :children, class_name: "Deck", foreign_key: "parent_id", dependent: :destroy
  has_many :cards, dependent: :restrict_with_error
  has_many :home_cards, class_name: "Card", foreign_key: "home_deck_id", dependent: :nullify

  # JSONB accessor for deck options
  store_accessor :options_json

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :name, uniqueness: { scope: [:user_id, :parent_id] }, if: -> { deleted_at.nil? }

  # Scopes
  scope :roots, -> { where(parent_id: nil) }
  scope :ordered, -> { order(:name) }

  # Returns all ancestor decks (parent, grandparent, etc.)
  # @return [Array<Deck>]
  def ancestors
    result = []
    current = parent
    while current
      result << current
      current = current.parent
    end
    result
  end

  # Returns all descendant IDs recursively
  # @return [Array<Integer>]
  def descendant_ids
    result = []
    children.each do |child|
      result << child.id
      result.concat(child.descendant_ids)
    end
    result
  end

  # Returns all descendant decks (children, grandchildren, etc.)
  # @return [ActiveRecord::Relation<Deck>]
  def descendants
    ids = descendant_ids
    return Deck.none if ids.empty?

    Deck.where(id: ids)
  end

  # Returns the full deck name with hierarchy (e.g., "Parent::Child::Grandchild")
  # @return [String]
  def full_name
    names = [name]
    current = parent
    while current
      names.unshift(current.name)
      current = current.parent
    end
    names.join("::")
  end

  # Checks if this deck is a root deck (no parent)
  # @return [Boolean]
  def root?
    parent_id.nil?
  end

  # Checks if this deck is a leaf deck (no children)
  # @return [Boolean]
  def leaf?
    children.empty?
  end
end
