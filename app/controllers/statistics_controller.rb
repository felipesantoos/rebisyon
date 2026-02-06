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
    Review.joins(card: :note)
          .where(notes: { user_id: current_user.id })
          .where(reviews: { created_at: @period_start..@period_end })
          .group_by_period(@period, "reviews.created_at", format: "%b %d")
          .count
  end

  # Review time per day (line chart)
  # @return [Hash] Data for chartkick
  def review_time_per_day_data
    Review.joins(card: :note)
          .where(notes: { user_id: current_user.id })
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
    reviews = Review.joins(card: :note)
                    .where(notes: { user_id: current_user.id })
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

  # Interval distribution (histogram) — computed in SQL to avoid loading all intervals into memory
  # @return [Hash] Data for chartkick
  def interval_distribution_data
    bins = [[1, 1], [2, 7], [8, 14], [15, 30], [31, 60], [61, 90], [91, 180], [181, 365], [366, 730], [731, nil]]

    case_sql = "CASE " + bins.map.with_index do |(min, max), i|
      if max.nil?
        "WHEN reviews.interval >= #{min} THEN #{i}"
      else
        "WHEN reviews.interval BETWEEN #{min} AND #{max} THEN #{i}"
      end
    end.join(" ") + " END"

    counts_by_bin = Review.joins(card: :note)
                          .where(notes: { user_id: current_user.id })
                          .where(reviews: { created_at: @period_start..@period_end })
                          .where(review_type: :review)
                          .where("reviews.interval >= 1")
                          .group(Arel.sql(case_sql))
                          .count

    bins.each_with_index.map do |(min, max), i|
      label = if max.nil?
                "#{min}+ days"
              elsif min == max
                "#{min} day"
              else
                "#{min}-#{max} days"
              end
      [label, counts_by_bin[i] || 0]
    end.to_h
  end

  # Card state breakdown (pie chart)
  # @return [Hash] Data for chartkick
  def card_state_breakdown_data
    Card.joins(:note)
        .where(notes: { user_id: current_user.id })
        .where(suspended: false, buried: false)
        .group(:state)
        .count
        .transform_keys { |k| k.humanize }
  end

  # Hourly breakdown (when you study)
  # @return [Hash] Data for chartkick
  def hourly_breakdown_data
    Review.joins(card: :note)
          .where(notes: { user_id: current_user.id })
          .where(reviews: { created_at: @period_start..@period_end })
          .group("EXTRACT(HOUR FROM reviews.created_at)")
          .count
          .transform_keys { |h| "#{h.to_i}:00" }
          .sort_by { |k, _| k.to_i }
          .to_h
  end

  # Deck overview with card counts — uses SQL aggregation instead of loading all cards
  # @return [Array<Hash>]
  def deck_overview_data
    root_decks = current_user.decks.roots.to_a
    return [] if root_decks.empty?

    # Build a mapping of root deck -> all descendant deck IDs (including self)
    all_decks = current_user.decks.where(deleted_at: nil).pluck(:id, :parent_id)
    children_map = all_decks.group_by(&:last).transform_values { |pairs| pairs.map(&:first) }

    deck_id_groups = root_decks.map do |deck|
      ids = [deck.id]
      queue = [deck.id]
      while (current_id = queue.shift)
        child_ids = children_map[current_id] || []
        ids.concat(child_ids)
        queue.concat(child_ids)
      end
      [deck.id, ids]
    end.to_h

    # Single query to get counts per deck_id
    all_deck_ids = deck_id_groups.values.flatten.uniq
    counts = Card.where(deck_id: all_deck_ids)
                 .group(:deck_id)
                 .select(
                   "deck_id",
                   "COUNT(*) AS total_count",
                   "COUNT(*) FILTER (WHERE state = 'new') AS new_count",
                   "COUNT(*) FILTER (WHERE state = 'learn') AS learn_count",
                   "COUNT(*) FILTER (WHERE state = 'review') AS review_count",
                   "COUNT(*) FILTER (WHERE state = 'relearn') AS relearn_count",
                   "COUNT(*) FILTER (WHERE suspended = true) AS suspended_count",
                   "COUNT(*) FILTER (WHERE buried = true) AS buried_count"
                 ).index_by(&:deck_id)

    root_decks.map do |deck|
      group_ids = deck_id_groups[deck.id]
      group_counts = group_ids.filter_map { |id| counts[id] }

      {
        deck: deck,
        total_cards: group_counts.sum { |c| c.total_count.to_i },
        new_cards: group_counts.sum { |c| c.new_count.to_i },
        learning_cards: group_counts.sum { |c| c.learn_count.to_i },
        review_cards: group_counts.sum { |c| c.review_count.to_i },
        relearn_cards: group_counts.sum { |c| c.relearn_count.to_i },
        suspended_cards: group_counts.sum { |c| c.suspended_count.to_i },
        buried_cards: group_counts.sum { |c| c.buried_count.to_i }
      }
    end
  end

  # Today's study statistics
  # @return [Hash]
  def today_stats_data
    today_reviews = Review.joins(card: :note)
                          .where(notes: { user_id: current_user.id })
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
