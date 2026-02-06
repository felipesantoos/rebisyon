# frozen_string_literal: true

class SharedDecksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shared_deck, only: %i[edit update destroy]

  def index
    @categories = SharedDeck.public_decks.distinct.pluck(:category).compact.sort
    @featured = SharedDeck.public_decks.featured.includes(:author).limit(6)

    scope = SharedDeck.public_decks.includes(:author)

    # Category filter
    scope = scope.where(category: params[:category]) if params[:category].present?

    # Search
    scope = scope.where("name ILIKE ?", "%#{params[:q]}%") if params[:q].present?

    # Sort
    scope = case params[:sort]
            when "top_rated"  then scope.top_rated
            when "newest"     then scope.order(created_at: :desc)
            else                   scope.popular
            end

    @pagy, @shared_decks = pagy(scope)
  end

  def show
    @shared_deck = SharedDeck.find(params[:id])
    @ratings = @shared_deck.shared_deck_ratings.includes(:user).order(created_at: :desc)
  end

  def new
    @shared_deck = SharedDeck.new
    @decks = current_user.decks.where(deleted_at: nil).order(:name)
  end

  def create
    @shared_deck = SharedDeck.new(shared_deck_params)
    @shared_deck.author = current_user

    if @shared_deck.save
      redirect_to shared_decks_path, notice: "Deck shared successfully."
    else
      @decks = current_user.decks.where(deleted_at: nil).order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @shared_deck.update(shared_deck_params)
      redirect_to @shared_deck, notice: "Shared deck updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @shared_deck.destroy
    redirect_to shared_decks_path, notice: "Shared deck deleted."
  end

  private

  def set_shared_deck
    @shared_deck = current_user.shared_decks.find(params[:id])
  end

  def shared_deck_params
    params.require(:shared_deck).permit(:name, :description, :category, :is_public, :deck_id)
  end
end
