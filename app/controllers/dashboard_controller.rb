# frozen_string_literal: true

class DashboardController < ApplicationController
  include DeckTreeBuilder

  before_action :authenticate_user!

  def show
    @deck_tree = build_deck_tree(current_user)
    @totals = compute_totals(@deck_tree)

    today_reviews = Review.joins(card: :deck)
                          .where(decks: { user_id: current_user.id })
                          .where("reviews.created_at >= ?", Time.current.beginning_of_day)
    @today_studied = today_reviews.count
    @today_minutes = (today_reviews.sum(:time_ms) / 60_000.0).round
  end
end
