# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    # Load deck statistics for the dashboard
    # Will be implemented when Deck model is available
    @deck_stats = []
    @total_due_cards = 0
    @total_new_cards = 0
    @total_learning_cards = 0
  end
end
