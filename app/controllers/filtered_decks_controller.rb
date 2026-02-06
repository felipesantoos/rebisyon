# frozen_string_literal: true

class FilteredDecksController < ApplicationController
  before_action :authenticate_user!

  def index
    @filtered_decks = helpers.mock_filtered_decks
  end

  def show
    @filtered_deck = helpers.mock_filtered_deck_detail
  end

  def new; end
  def edit; end

  def create
    redirect_to filtered_decks_path, notice: "Filtered deck created."
  end

  def update
    redirect_to filtered_decks_path, notice: "Filtered deck updated."
  end

  def destroy
    redirect_to filtered_decks_path, notice: "Filtered deck deleted."
  end
end
