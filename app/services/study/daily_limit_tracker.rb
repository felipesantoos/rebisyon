# frozen_string_literal: true

module Study
  # Tracks daily limits for new cards and reviews per user
  #
  # Uses a simple in-memory cache (can be upgraded to Solid Cache later)
  # Tracks counts per day and resets at day boundary
  #
  # @example
  #   tracker = Study::DailyLimitTracker.new(user)
  #   tracker.increment_new_cards(deck)
  #   tracker.can_study_new?(deck) # => true/false
  class DailyLimitTracker
    attr_reader :user

    def initialize(user)
      @user = user
    end

    # Increments the new cards count for a deck today
    # @param deck [Deck]
    def increment_new_cards(deck)
      key = new_cards_key(deck)
      current = get_count(key)
      set_count(key, current + 1)
    end

    # Increments the review count for a deck today
    # @param deck [Deck]
    def increment_reviews(deck)
      key = reviews_key(deck)
      current = get_count(key)
      set_count(key, current + 1)
    end

    # Checks if user can study new cards for a deck today
    # @param deck [Deck]
    # @return [Boolean]
    def can_study_new?(deck)
      limit = new_cards_limit(deck)
      return true if limit.zero? # No limit

      current = get_count(new_cards_key(deck))
      current < limit
    end

    # Checks if user can study reviews for a deck today
    # @param deck [Deck]
    # @return [Boolean]
    def can_study_reviews?(deck)
      limit = reviews_limit(deck)
      return true if limit.zero? # No limit

      current = get_count(reviews_key(deck))
      current < limit
    end

    # Gets the current new cards count for a deck today
    # @param deck [Deck]
    # @return [Integer]
    def new_cards_count(deck)
      get_count(new_cards_key(deck))
    end

    # Gets the current review count for a deck today
    # @param deck [Deck]
    # @return [Integer]
    def reviews_count(deck)
      get_count(reviews_key(deck))
    end

    # Resets all counts for today (called at day boundary)
    def reset
      # Clear all keys for this user
      # In a real implementation, this would use Solid Cache or Redis
      # For now, we'll rely on the day-based key expiration
    end

    private

    # Gets new cards limit from deck options
    # @param deck [Deck]
    # @return [Integer]
    def new_cards_limit(deck)
      options = deck.options_json || {}
      options["new_per_day"] || 20
    end

    # Gets reviews limit from deck options
    # @param deck [Deck]
    # @return [Integer]
    def reviews_limit(deck)
      options = deck.options_json || {}
      options["reviews_per_day"] || 200
    end

    # Generates cache key for new cards count
    # @param deck [Deck]
    # @return [String]
    def new_cards_key(deck)
      "daily_limit:user:#{user.id}:deck:#{deck.id}:new:#{today_key}"
    end

    # Generates cache key for reviews count
    # @param deck [Deck]
    # @return [String]
    def reviews_key(deck)
      "daily_limit:user:#{user.id}:deck:#{deck.id}:reviews:#{today_key}"
    end

    # Gets today's date key (YYYY-MM-DD)
    # @return [String]
    def today_key
      Time.current.to_date.to_s
    end

    # Gets count from cache
    # @param key [String]
    # @return [Integer]
    def get_count(key)
      # Use Solid Cache if available, otherwise in-memory
      if defined?(SolidCache)
        SolidCache.read(key).to_i
      else
        @cache ||= {}
        @cache[key] ||= 0
      end
    end

    # Sets count in cache
    # @param key [String]
    # @param value [Integer]
    def set_count(key, value)
      # Use Solid Cache if available, otherwise in-memory
      if defined?(SolidCache)
        SolidCache.write(key, value, expires_in: 1.day)
      else
        @cache ||= {}
        @cache[key] = value
      end
    end
  end
end
