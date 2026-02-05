# frozen_string_literal: true

module Study
  # Automatically buries sibling cards (other cards from the same note)
  #
  # When a card is answered, its siblings can be automatically buried
  # to prevent seeing multiple cards from the same note in one session.
  #
  # @example
  #   burier = Study::SiblingBurier.new(card, deck)
  #   burier.bury_siblings if burier.should_bury?
  class SiblingBurier
    attr_reader :card, :deck

    def initialize(card, deck)
      @card = card
      @deck = deck
    end

    # Checks if siblings should be buried based on deck options
    # @return [Boolean]
    def should_bury?
      options = deck_options
      
      case card.state.to_s
      when "new"
        options["bury_new"] == true
      when "review"
        options["bury_reviews"] == true
      when "learn", "relearn"
        options["bury_interday_learning"] == true
      else
        false
      end
    end

    # Buries all sibling cards
    # @return [Integer] Number of cards buried
    def bury_siblings
      return 0 unless should_bury?

      siblings = card.siblings.active
      count = siblings.count
      siblings.update_all(buried: true, updated_at: Time.current)
      count
    end

    private

    # Gets deck options
    # @return [Hash]
    def deck_options
      deck.options_json || {}
    end
  end
end
