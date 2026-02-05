# frozen_string_literal: true

module Study
  # Processes a card answer and updates the card accordingly
  #
  # Handles:
  # - Scheduling the next review using SM-2
  # - Creating review records
  # - Detecting leeches
  # - Burying siblings
  # - Tracking daily limits
  #
  # @example
  #   processor = Study::AnswerProcessor.new(card, deck, user)
  #   result = processor.process(rating: 3, time_ms: 5000)
  class AnswerProcessor
    attr_reader :card, :deck, :user

    def initialize(card, deck, user)
      @card = card
      @deck = deck
      @user = user
    end

    # Processes the answer
    # @param rating [Integer] 1=Again, 2=Hard, 3=Good, 4=Easy
    # @param time_ms [Integer] Time taken to answer in milliseconds
    # @return [Hash] Result with updated card and review
    def process(rating:, time_ms:)
      ActiveRecord::Base.transaction do
        # Get scheduler based on deck options
        scheduler = get_scheduler

        # Process answer based on card state
        update_attrs = case card.state.to_s
                      when "new"
                        scheduler.answer_new(rating: rating)
                      when "learn"
                        scheduler.answer_learning(rating: rating)
                      when "review"
                        scheduler.answer_review(rating: rating)
                      when "relearn"
                        scheduler.answer_relearning(rating: rating)
                      else
                        raise ArgumentError, "Invalid card state: #{card.state}"
                      end

        # Update card
        card.update!(update_attrs)

        # Create review record
        review = create_review(rating, time_ms)

        # Detect and handle leeches
        leech_detector = LeechDetector.new(card, deck)
        leech_detected = leech_detector.handle_leech if leech_detector.detect?

        # Bury siblings if configured
        sibling_burier = SiblingBurier.new(card, deck)
        siblings_buried = sibling_burier.bury_siblings if sibling_burier.should_bury?

        # Track daily limits
        tracker = DailyLimitTracker.new(user)
        if card.state == "new" && card.state_before_last_save != "new"
          tracker.increment_new_cards(deck)
        end
        if card.state == "review" || card.state == "learn" || card.state == "relearn"
          tracker.increment_reviews(deck)
        end

        {
          card: card.reload,
          review: review,
          leech_detected: leech_detected,
          siblings_buried: siblings_buried
        }
      end
    end

    private

    # Gets the appropriate scheduler based on deck options
    # @return [Scheduling::Sm2Scheduler]
    def get_scheduler
      options = deck.options_json || {}
      scheduler_type = options["scheduler"] || "sm2"

      case scheduler_type
      when "sm2"
        Scheduling::Sm2Scheduler.new(card, deck)
      else
        # Default to SM-2
        Scheduling::Sm2Scheduler.new(card, deck)
      end
    end

    # Creates a review record
    # @param rating [Integer]
    # @param time_ms [Integer]
    # @return [Review]
    def create_review(rating, time_ms)
      review_type_value = case card.state.to_s
                          when "new", "learn"
                            :learn
                          when "review"
                            :review
                          when "relearn"
                            :relearn
                          else
                            :review
                          end

      Review.create!(
        card: card,
        rating: rating,
        interval: card.interval,
        ease: card.ease,
        time_ms: time_ms,
        review_type: review_type_value
      )
    end
  end
end
