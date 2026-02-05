# frozen_string_literal: true

module Study
  # Detects leech cards (cards with too many lapses)
  #
  # A leech is a card that has been forgotten many times, indicating
  # it may be too difficult or poorly formulated.
  #
  # @example
  #   detector = Study::LeechDetector.new(card, deck)
  #   if detector.detect?
  #     detector.handle_leech # Tags or suspends the card
  #   end
  class LeechDetector
    attr_reader :card, :deck

    def initialize(card, deck)
      @card = card
      @deck = deck
    end

    # Checks if the card is a leech
    # @param threshold [Integer] Number of lapses to consider a leech (default: from deck options)
    # @return [Boolean]
    def detect?(threshold: nil)
      threshold ||= leech_threshold
      card.lapses >= threshold
    end

    # Handles a detected leech based on deck options
    # Options: tag only, suspend, or both
    # @return [Boolean] true if leech was handled
    def handle_leech
      return false unless detect?

      options = deck_options
      action = options["leech_action"] || "tag_only"

      case action
      when "suspend", "tag_and_suspend"
        card.update!(suspended: true)
      end

      case action
      when "tag_only", "tag_and_suspend"
        tag_leech
      end

      true
    end

    private

    # Gets leech threshold from deck options
    # @return [Integer]
    def leech_threshold
      options = deck_options
      options["leech_threshold"] || 8
    end

    # Gets deck options
    # @return [Hash]
    def deck_options
      deck.options_json || {}
    end

    # Tags the note as a leech
    def tag_leech
      note = card.note
      tags = note.tags.dup
      tags << "leech" unless tags.include?("leech")
      note.update!(tags: tags)
    end
  end
end
