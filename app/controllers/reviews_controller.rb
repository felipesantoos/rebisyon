# frozen_string_literal: true

class ReviewsController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!

  def index
    reviews = Review.joins(card: :deck)
                    .where(decks: { user_id: current_user.id })
                    .includes(card: [:deck, :note])
                    .order(created_at: :desc)

    # Filter by deck
    if params[:deck_id].present?
      reviews = reviews.where(cards: { deck_id: params[:deck_id] })
    end

    # Filter by rating
    if params[:rating].present?
      reviews = reviews.where(rating: params[:rating])
    end

    # Filter by type
    if params[:type].present?
      reviews = reviews.where(type: params[:type])
    end

    @pagy, @reviews = pagy(reviews, limit: 50)
    @decks = current_user.decks.where(deleted_at: nil).order(:name)
  end
end
