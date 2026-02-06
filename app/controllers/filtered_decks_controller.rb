# frozen_string_literal: true

class FilteredDecksController < ApplicationController
  include Paginatable

  before_action :authenticate_user!
  before_action :set_filtered_deck, only: %i[show edit update destroy]

  def index
    @pagy, @filtered_decks = paginate(current_user.filtered_decks.ordered)
  end

  def show
  end

  def new
    @filtered_deck = current_user.filtered_decks.build
  end

  def edit
  end

  def create
    @filtered_deck = current_user.filtered_decks.build(filtered_deck_params)
    if @filtered_deck.save
      redirect_to @filtered_deck, notice: "Filtered deck created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @filtered_deck.update(filtered_deck_params)
      redirect_to @filtered_deck, notice: "Filtered deck updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @filtered_deck.soft_delete!
    redirect_to filtered_decks_path, notice: "Filtered deck deleted."
  end

  private

  def set_filtered_deck
    @filtered_deck = current_user.filtered_decks.find(params[:id])
  end

  def filtered_deck_params
    params.require(:filtered_deck).permit(:name, :search_filter, :second_filter, :limit_cards, :order_by, :reschedule)
  end
end
