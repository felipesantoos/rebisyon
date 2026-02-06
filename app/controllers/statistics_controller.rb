# frozen_string_literal: true

class StatisticsController < ApplicationController
  before_action :authenticate_user!

  def show
    @period = params[:period] || "week"
    @period_start = period_start(@period)
    @period_end = Time.current

    # Cache statistics for 5 minutes
    cache_key = "statistics:user:#{current_user.id}:period:#{@period}:#{@period_start.to_date}"
    @statistics = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      build_statistics
    end
  end

  private

  # Builds all statistics data
  # @return [Hash]
  def build_statistics
    {
      reviews_per_day: reviews_per_day_data,
      review_time_per_day: review_time_per_day_data,
      retention_rate: retention_rate_data,
      interval_distribution: interval_distribution_data,
      card_state_breakdown: card_state_breakdown_data,
      hourly_breakdown: hourly_breakdown_data,
      deck_overview: deck_overview_data,
      today_stats: today_stats_data
    }
  end

  # Reviews per day (bar chart)
  # @return [Hash] Data for chartkick
  def reviews_per_day_data
    Review.joins(card: :deck)
          .where(decks: { user_id: current_user.id })
          .where(reviews: { created_at: @period_start..@period_end })
          .group_by_period(@period, "reviews.created_at", format: "%b %d")
          .count
  end

  # Review time per day (line chart)
  # @return [Hash] Data for chartkick
  def review_time_per_day_data
    Review.joins(card: :deck)
          .where(decks: { user_id: current_user.id })
          .where(reviews: { created_at: @period_start..@period_end })
          .group_by_period(@period, "reviews.created_at", format: "%b %d")
          .sum("reviews.time_ms")
          .transform_values { |ms| (ms / 1000.0 / 60.0).round(1) } # Convert to minutes
  end

  # Retention rate (% correct by maturity)
  # @return [Hash] Data for chartkick
  def retention_rate_data
    # Group reviews by interval (maturity) and calculate % correct (rating >= 3)
    # Note: Using string 'review' because PostgreSQL enum types are string-based
    reviews = Review.joins(card: :deck)
                    .where(decks: { user_id: current_user.id })
                    .where(reviews: { created_at: @period_start..@period_end })
                    .where(review_type: :review) # Only review cards, not learning

    # Group by interval ranges and calculate retention
    retention_by_range = {}

    ["1 day", "2-7 days", "8-30 days", "31-90 days", "91-365 days", "365+ days"].each do |range|
      range_bounds = range_to_interval_bounds(range)
      if range_bounds.nil?
        # 365+ days
        range_reviews = reviews.where("reviews.interval >= ?", 366)
      else
        range_reviews = reviews.where("reviews.interval" => range_bounds)
      end

      total = range_reviews.count
      correct = range_reviews.where("reviews.rating >= ?", 3).count
      percentage = total.positive? ? ((correct.to_f / total) * 100).round(1) : 0
      retention_by_range[range] = percentage
    end

    retention_by_range
  end

  # Converts range string to interval bounds for SQL query
  # @param range [String]
  # @return [Range, nil] Range object or nil for open-ended
  def range_to_interval_bounds(range)
    case range
    when "1 day"
      1..1
    when "2-7 days"
      2..7
    when "8-30 days"
      8..30
    when "31-90 days"
      31..90
    when "91-365 days"
      91..365
    when "365+ days"
      nil # Will use >= 366
    else
      nil
    end
  end

  # Interval distribution (histogram)
  # @return [Hash] Data for chartkick
  def interval_distribution_data
    intervals = Review.joins(card: :deck)
                      .where(decks: { user_id: current_user.id })
                      .where(reviews: { created_at: @period_start..@period_end })
                      .where(review_type: :review) # Use enum value
                      .pluck("reviews.interval")

    # Create bins for histogram
    bins = [[1, 1], [2, 7], [8, 14], [15, 30], [31, 60], [61, 90], [91, 180], [181, 365], [366, 730], [731, nil]]
    distribution = bins.map do |min, max|
      if max.nil?
        count = intervals.count { |i| i >= min }
        label = "#{min}+ days"
      else
        count = intervals.count { |i| i >= min && i <= max }
        label = min == max ? "#{min} day" : "#{min}-#{max} days"
      end
      [label, count]
    end.to_h

    distribution
  end

  # Card state breakdown (pie chart)
  # @return [Hash] Data for chartkick
  def card_state_breakdown_data
    Card.joins(:deck)
        .where(decks: { user_id: current_user.id })
        .where(suspended: false, buried: false)
        .group(:state)
        .count
        .transform_keys { |k| k.humanize }
  end

  # Hourly breakdown (when you study)
  # @return [Hash] Data for chartkick
  def hourly_breakdown_data
    Review.joins(card: :deck)
          .where(decks: { user_id: current_user.id })
          .where(reviews: { created_at: @period_start..@period_end })
          .group("EXTRACT(HOUR FROM reviews.created_at)")
          .count
          .transform_keys { |h| "#{h.to_i}:00" }
          .sort_by { |k, _| k.to_i }
          .to_h
  end

  # Deck overview with card counts
  # @return [Array<Hash>]
  def deck_overview_data
    current_user.decks.roots.map do |deck|
      all_cards = deck.cards + deck.descendants.flat_map(&:cards)
      {
        deck: deck,
        total_cards: all_cards.count,
        new_cards: all_cards.count { |c| c.state == "new" },
        learning_cards: all_cards.count { |c| c.state == "learn" },
        review_cards: all_cards.count { |c| c.state == "review" },
        relearn_cards: all_cards.count { |c| c.state == "relearn" },
        suspended_cards: all_cards.count(&:suspended),
        buried_cards: all_cards.count(&:buried)
      }
    end
  end

  # Today's study statistics
  # @return [Hash]
  def today_stats_data
    today_reviews = Review.joins(card: :deck)
                          .where(decks: { user_id: current_user.id })
                          .where(reviews: { created_at: Time.current.beginning_of_day..Time.current })

    total = today_reviews.count
    correct = today_reviews.where("reviews.rating >= ?", 3).count
    again = today_reviews.where(rating: 1).count
    time_ms = today_reviews.sum(:time_ms)
    minutes = (time_ms / 60_000.0).round

    {
      studied: total,
      time_spent: "#{minutes}m",
      correct_percent: total.positive? ? ((correct.to_f / total) * 100).round(1) : 0,
      again_count: again
    }
  end

  # Gets the start of the period
  # @param period [String] "week", "month", or "year"
  # @return [Time]
  def period_start(period)
    case period
    when "week"
      1.week.ago
    when "month"
      1.month.ago
    when "year"
      1.year.ago
    else
      1.week.ago
    end
  end

end
