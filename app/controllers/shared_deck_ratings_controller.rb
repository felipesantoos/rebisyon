# frozen_string_literal: true

class SharedDeckRatingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shared_deck
  before_action :set_rating, only: %i[update destroy]

  def create
    @rating = current_user.shared_deck_ratings.build(rating_params.merge(shared_deck: @shared_deck))

    if @rating.save
      recalculate_average
      redirect_back fallback_location: shared_deck_path(@shared_deck), notice: "Rating submitted."
    else
      redirect_back fallback_location: shared_deck_path(@shared_deck), alert: "Could not submit rating."
    end
  end

  def update
    if @rating.update(rating_params)
      recalculate_average
      redirect_back fallback_location: shared_deck_path(@shared_deck), notice: "Rating updated."
    else
      redirect_back fallback_location: shared_deck_path(@shared_deck), alert: "Could not update rating."
    end
  end

  def destroy
    @rating.destroy
    recalculate_average
    redirect_back fallback_location: shared_deck_path(@shared_deck), notice: "Rating removed."
  end

  private

  def set_shared_deck
    @shared_deck = SharedDeck.find(params[:shared_deck_id])
  end

  def set_rating
    @rating = current_user.shared_deck_ratings.find(params[:id])
  end

  def rating_params
    params.require(:shared_deck_rating).permit(:rating, :comment)
  end

  def recalculate_average
    @shared_deck.update(rating_average: @shared_deck.shared_deck_ratings.average(:rating))
  end
end
