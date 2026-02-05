# frozen_string_literal: true

class DecksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deck, only: %i[show edit update destroy]

  # GET /decks
  def index
    @decks = current_user.decks.roots.ordered
  end

  # GET /decks/:id
  def show
  end

  # GET /decks/new
  def new
    @deck = current_user.decks.build
    @deck.parent_id = params[:parent_id] if params[:parent_id].present?
  end

  # GET /decks/:id/edit
  def edit
  end

  # POST /decks
  def create
    @deck = current_user.decks.build(deck_params)

    if @deck.save
      redirect_to @deck, notice: "Deck was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /decks/:id
  def update
    if @deck.update(deck_params)
      redirect_to @deck, notice: "Deck was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /decks/:id
  def destroy
    @deck.soft_delete!
    redirect_to decks_url, notice: "Deck was successfully deleted."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_deck
    @deck = current_user.decks.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def deck_params
    params.require(:deck).permit(:name, :parent_id, options_json: {})
  end
end
