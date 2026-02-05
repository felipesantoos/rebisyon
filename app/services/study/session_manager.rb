# frozen_string_literal: true

module Study
  # Manages a study session for a deck
  #
  # Orchestrates the study experience:
  # - Builds card queue
  # - Provides next card
  # - Processes answers
  # - Tracks session statistics
  #
  # @example
  #   manager = Study::SessionManager.new(deck, user)
  #   next_card = manager.next_card
  #   result = manager.answer_card(card, rating: 3, time_ms: 5000)
  class SessionManager
    attr_reader :deck, :user, :queue, :session_started_at

    def initialize(deck, user)
      @deck = deck
      @user = user
      @queue = []
      @session_started_at = Time.current
      @studied_cards = []
    end

    # Gets the next card from the queue
    # @return [Card, nil]
    def next_card
      build_queue if queue.empty?
      queue.shift
    end

    # Processes an answer for a card
    # @param card [Card]
    # @param rating [Integer] 1=Again, 2=Hard, 3=Good, 4=Easy
    # @param time_ms [Integer] Time taken to answer in milliseconds
    # @return [Hash] Result with updated card and review
    def answer_card(card, rating:, time_ms:)
      processor = AnswerProcessor.new(card, deck, user)
      result = processor.process(rating: rating, time_ms: time_ms)
      @studied_cards << result[:card]
      result
    end

    # Gets session statistics
    # @return [Hash]
    def statistics
      {
        cards_studied: @studied_cards.length,
        session_duration: Time.current - session_started_at,
        deck: deck.name
      }
    end

    # Checks if there are more cards to study
    # @return [Boolean]
    def has_more_cards?
      build_queue if queue.empty?
      !queue.empty?
    end

    private

    # Builds the card queue
    def build_queue
      builder = CardQueueBuilder.new(deck, user)
      @queue = builder.build
    end
  end
end
