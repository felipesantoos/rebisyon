# frozen_string_literal: true

class SharedDeckRatingsController < ApplicationController
  before_action :authenticate_user!

  def create
    redirect_back fallback_location: shared_decks_path, notice: "Rating submitted."
  end

  def update
    redirect_back fallback_location: shared_decks_path, notice: "Rating updated."
  end

  def destroy
    redirect_back fallback_location: shared_decks_path, notice: "Rating removed."
  end
end
