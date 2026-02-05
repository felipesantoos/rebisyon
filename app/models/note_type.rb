# frozen_string_literal: true

class NoteType < ApplicationRecord
  include SoftDeletable
  include UserScoped

  # Associations
  has_many :notes, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :name, uniqueness: { scope: [:user_id, :deleted_at] }, if: -> { deleted_at.nil? }
  validates :fields_json, presence: true
  validates :card_types_json, presence: true
  validates :templates_json, presence: true

  # Scopes
  scope :ordered, -> { order(:name) }

  # JSONB accessors for structured data
  # fields_json: Array of field definitions
  #   [{"name": "Front", "ord": 0}, {"name": "Back", "ord": 1}]
  # card_types_json: Array of card type definitions
  #   [{"name": "Forward", "ord": 0}, {"name": "Reverse", "ord": 1}]
  # templates_json: Hash of templates
  #   {"Front": "...", "Back": "...", "Styling": "..."}

  # Returns fields as an array
  # @return [Array<Hash>]
  def fields
    fields_json.is_a?(Array) ? fields_json : []
  end

  # Sets fields from an array
  # @param value [Array<Hash>]
  def fields=(value)
    self.fields_json = value.is_a?(Array) ? value : []
  end

  # Returns card types as an array
  # @return [Array<Hash>]
  def card_types
    card_types_json.is_a?(Array) ? card_types_json : []
  end

  # Sets card types from an array
  # @param value [Array<Hash>]
  def card_types=(value)
    self.card_types_json = value.is_a?(Array) ? value : []
  end

  # Returns templates as a hash
  # @return [Hash]
  def templates
    templates_json.is_a?(Hash) ? templates_json : {}
  end

  # Sets templates from a hash
  # @param value [Hash]
  def templates=(value)
    self.templates_json = value.is_a?(Hash) ? value : {}
  end

  # Returns array of field names
  # @return [Array<String>]
  def field_names
    fields.map { |f| f["name"] || f[:name] }.compact
  end

  # Returns array of card type names
  # @return [Array<String>]
  def card_type_names
    card_types.map { |ct| ct["name"] || ct[:name] }.compact
  end
end
