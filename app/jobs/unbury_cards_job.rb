# frozen_string_literal: true

# Job to unbury cards at day boundary
#
# Cards that are buried should be automatically unburied at the start of a new day
# so they can be studied again.
#
# This job should be scheduled to run daily (e.g., via cron or Solid Queue recurring jobs)
class UnburyCardsJob < ApplicationJob
  queue_as :default

  # Unburies all buried cards for a user
  # @param user_id [Integer]
  def perform(user_id)
    user = User.find(user_id)
    
    # Unbury all active buried cards
    user.cards.active.where(buried: true).update_all(
      buried: false,
      updated_at: Time.current
    )
  end
end
