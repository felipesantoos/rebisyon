# frozen_string_literal: true

module Cards
  # Generates cards for a note based on its note_type's card_types configuration
  #
  # @example
  #   note = Note.find(1)
  #   deck = Deck.find(1)
  #   Cards::Generator.new(note, deck: deck).call
  class Generator
    attr_reader :note, :deck

    def initialize(note, deck: nil)
      @note = note
      @deck = deck
    end

    # Generates cards for the note
    # @return [Array<Card>] Array of created cards
    def call
      return [] if note.note_type.nil?

      card_types = note.note_type.card_types
      return [] if card_types.empty?

      # Get deck: use provided deck, or note's temporary deck_id, or user's first deck
      target_deck = deck || (note.respond_to?(:deck_id) && note.deck_id ? note.user.decks.find_by(id: note.deck_id) : nil) || note.user.decks.first
      return [] unless target_deck

      cards = []
      card_types.each_with_index do |card_type, index|
        card = create_card_for_type(card_type, index, target_deck)
        cards << card if card
      end

      cards
    end

    private

    # Creates a card for a specific card type
    # @param card_type [Hash] Card type definition from note_type
    # @param card_type_id [Integer] Index of the card type
    # @param deck [Deck] Deck to assign the card to
    # @return [Card, nil]
    def create_card_for_type(card_type, card_type_id, deck)
      Card.create!(
        note: note,
        card_type_id: card_type_id,
        deck: deck,
        home_deck: nil,
        state: :new,
        due: 0,
        interval: 0,
        ease: 2500,
        lapses: 0,
        reps: 0,
        position: 0,
        flag: 0,
        suspended: false,
        buried: false
      )
    end
  end
end
