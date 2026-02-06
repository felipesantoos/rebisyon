# frozen_string_literal: true

# Job to reset daily limit counters at day boundary
#
# Daily limits for new cards and reviews should be reset each day.
# This job should be scheduled to run daily (e.g., via cron or Solid Queue recurring jobs)
class DailyResetJob < ApplicationJob
  queue_as :default

  # Resets daily limits for all users and unburies cards
  def perform
    User.find_each do |user|
      Study::DailyLimitTracker.new(user).reset
      UnburyCardsJob.perform_later(user.id)
    end

    Rails.logger.info "Daily reset job completed at #{Time.current}"
  end
end
