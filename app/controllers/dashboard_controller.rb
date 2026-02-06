# frozen_string_literal: true

class DashboardController < ApplicationController
  include MockDataHelper

  before_action :authenticate_user!

  def show
    @deck_tree = mock_deck_tree
    @totals = mock_deck_totals
  end
end
