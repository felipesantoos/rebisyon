# frozen_string_literal: true

class Note < ApplicationRecord
  include SoftDeletable
  include UserScoped

  # Associations
  belongs_to :note_type
  has_many :cards, dependent: :destroy
  has_many :note_media, dependent: :destroy
  has_many :media, through: :note_media

  # Temporary attribute for deck_id (used during creation)
  attr_accessor :deck_id

  # Validations
  validates :guid, presence: true, uniqueness: { scope: :deleted_at, conditions: -> { where(deleted_at: nil) } }
  validates :guid, format: { with: /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i }
  validates :fields_json, presence: true

  # Callbacks
  before_validation :generate_guid, on: :create
  after_create :generate_cards
  after_update :regenerate_cards, if: :saved_change_to_fields_json?
  after_save :associate_media

  # Scopes
  scope :tagged, ->(tag) { where("? = ANY(tags)", tag) }
  scope :marked, -> { where(marked: true) }

  # Generates a GUID for the note if one doesn't exist
  # @return [String] UUID v4 format
  def generate_guid
    self.guid ||= SecureRandom.uuid
  end

  # Gets the first field value (used for validation)
  # @return [String, nil]
  def first_field
    return nil unless fields_json.is_a?(Hash)

    field_names = note_type&.field_names || []
    return nil if field_names.empty?

    fields_json[field_names.first.to_s]
  end

  # Validates that the first field is present
  validate :first_field_present

  private

  # Validates that the first field has content
  def first_field_present
    return if note_type.nil?

    first_field_value = first_field
    if first_field_value.blank?
      field_name = note_type.field_names.first
      errors.add(:fields_json, "must have content in the first field (#{field_name})")
    end
  end

  # Generates cards for this note based on note_type card_types
  # @param deck [Deck, nil] Optional deck to assign cards to
  def generate_cards(deck: nil)
    deck ||= (deck_id ? user.decks.find_by(id: deck_id) : nil) if respond_to?(:deck_id)
    Cards::Generator.new(self, deck: deck).call
  end

  # Regenerates cards when fields change
  def regenerate_cards
    # Preserve deck from first card if it exists
    existing_deck = cards.first&.deck
    cards.destroy_all
    generate_cards(deck: existing_deck)
  end

  # Associates media based on references in fields
  def associate_media
    Media::ReferenceParser.new(self).parse_and_associate
  end
end

