# frozen_string_literal: true

class SharedDecksController < ApplicationController
  before_action :authenticate_user!

  def index
    @shared_decks = helpers.mock_shared_decks
    @categories = helpers.mock_shared_deck_categories
    @featured = helpers.mock_featured_shared_decks
  end

  def show
    @shared_deck = helpers.mock_shared_deck_detail
    @ratings = helpers.mock_shared_deck_ratings
  end

  def new; end

  def create
    redirect_to shared_decks_path, notice: "Deck shared successfully."
  end
end
