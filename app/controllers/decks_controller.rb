# frozen_string_literal: true

class DecksController < ApplicationController
  include DeckTreeBuilder

  before_action :authenticate_user!
  before_action :set_deck, only: %i[show edit update destroy]

  # GET /decks
  def index
    @deck_tree = build_deck_tree(current_user)
    @totals = compute_totals(@deck_tree)
  end

  # GET /decks/:id
  def show
    counts = Card.where(deck_id: [@deck.id] + @deck.descendant_ids)
                 .where(suspended: false, buried: false)
                 .select(
                   "COUNT(*) FILTER (WHERE state = 'new') AS new_count",
                   "COUNT(*) FILTER (WHERE state IN ('learn', 'relearn')) AS learn_count",
                   "COUNT(*) FILTER (WHERE state = 'review' AND due <= #{Card.sanitize_sql_for_conditions(["?", (Time.current.to_f * 1000).to_i])}) AS due_count",
                   "COUNT(*) AS total_count"
                 ).take

    @new_count = counts&.new_count.to_i
    @learn_count = counts&.learn_count.to_i
    @due_count = counts&.due_count.to_i
    @total_cards = counts&.total_count.to_i
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
