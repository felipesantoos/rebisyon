# frozen_string_literal: true

# Job to reset daily limit counters at day boundary
#
# Daily limits for new cards and reviews should be reset each day.
# This job should be scheduled to run daily (e.g., via cron or Solid Queue recurring jobs)
class DailyResetJob < ApplicationJob
  queue_as :default

  # Resets daily limits for all users
  def perform
    # The DailyLimitTracker uses date-based keys, so old keys will naturally expire
    # However, we can explicitly clear them if needed
    
    # For now, we rely on the date-based key expiration in DailyLimitTracker
    # In a production system with Solid Cache, we could:
    # - Delete keys matching the pattern "daily_limit:*:YYYY-MM-DD" for yesterday
    # - Or rely on TTL expiration
    
    # This is a placeholder - actual implementation depends on cache backend
    Rails.logger.info "Daily reset job completed at #{Time.current}"
  end
end
