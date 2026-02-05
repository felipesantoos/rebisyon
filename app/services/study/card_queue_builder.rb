# frozen_string_literal: true

module Study
  # Builds the card queue for a study session
  #
  # Queue order:
  # 1. Learning cards due (learn, relearn states)
  # 2. Review cards due
  # 3. New cards (respecting daily limits)
  #
  # @example
  #   builder = Study::CardQueueBuilder.new(deck, user)
  #   queue = builder.build
  class CardQueueBuilder
    attr_reader :deck, :user

    def initialize(deck, user)
      @deck = deck
      @user = user
    end

    # Builds the card queue
    # @return [Array<Card>] Queue of cards to study
    def build
      queue = []
      timestamp = current_timestamp
      tracker = DailyLimitTracker.new(user)

      # 1. Learning cards due (learn and relearn states)
      learning_cards = deck.cards
                          .active
                          .due_for_learning(timestamp)
                          .order(:due, :id)
                          .limit(100) # Reasonable limit per session
      queue.concat(learning_cards.to_a)

      # 2. Review cards due
      review_cards = deck.cards
                        .active
                        .due_for_review(timestamp)
                        .order(:due, :id)
                        .limit(100)
      queue.concat(review_cards.to_a)

      # 3. New cards (respecting daily limits)
      if tracker.can_study_new?(deck)
        remaining_limit = new_cards_limit - tracker.new_cards_count(deck)
        new_cards = deck.cards
                       .active
                       .new_cards
                       .order(:position, :id)
                       .limit(remaining_limit)
        queue.concat(new_cards.to_a)
      end

      queue
    end

    private

    # Gets current timestamp in milliseconds
    # @return [Integer]
    def current_timestamp
      (Time.current.to_f * 1000).to_i
    end

    # Gets new cards limit from deck options
    # @return [Integer]
    def new_cards_limit
      options = deck.options_json || {}
      options["new_per_day"] || 20
    end
  end
end
