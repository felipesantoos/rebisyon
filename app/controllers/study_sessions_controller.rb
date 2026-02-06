# frozen_string_literal: true

class StudySessionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_deck
  before_action :initialize_session_manager

  # GET /decks/:deck_id/study
  def show
    @card = @session_manager.next_card

    if @card.nil?
      redirect_to deck_path(@deck), notice: "No cards to study right now."
      return
    end

    # Render card question side
    @note = @card.note
    @note_type = @note.note_type
    @card_front = render_card_front(@card)
    @session_stats = @session_manager.statistics
  end

  # POST /decks/:deck_id/study/show_answer
  def show_answer
    @card = current_user.cards.find(params[:card_id])
    @note = @card.note
    @note_type = @note.note_type
    @card_back = render_card_back(@card)
    
    respond_to do |format|
      format.html { redirect_to deck_study_path(@deck) }
      format.turbo_stream
    end
  end

  # POST /decks/:deck_id/study/answer
  def answer
    @card = current_user.cards.find(params[:card_id])
    rating = params[:rating].to_i
    time_ms = params[:time_ms].to_i

    unless (1..4).include?(rating)
      redirect_to deck_study_path(@deck), alert: "Invalid rating."
      return
    end

    # Snapshot card state for undo before processing
    session[:last_answer_undo] = {
      card_id: @card.id,
      attributes: @card.attributes.slice(
        "state", "due", "interval", "ease", "lapses", "reps",
        "position", "flag", "suspended", "buried"
      )
    }

    # Process the answer
    result = @session_manager.answer_card(@card, rating: rating, time_ms: time_ms)
    @next_card = @session_manager.next_card
    @session_stats = @session_manager.statistics

    respond_to do |format|
      format.html do
        if @next_card
          redirect_to deck_study_path(@deck)
        else
          redirect_to deck_path(@deck), notice: "Study session complete!"
        end
      end
      format.turbo_stream
    end
  end

  # GET /decks/:deck_id/study/congrats
  def congrats
    @session_stats = @session_manager.statistics
  end

  # POST /decks/:deck_id/study/undo
  def undo
    undo_data = session.delete(:last_answer_undo)

    unless undo_data
      redirect_to deck_study_session_path(@deck), alert: "Nothing to undo."
      return
    end

    card = current_user.cards.find_by(id: undo_data["card_id"])

    unless card
      redirect_to deck_study_session_path(@deck), alert: "Card not found."
      return
    end

    # Restore card attributes and delete the last review
    Card.transaction do
      card.update!(undo_data["attributes"])
      card.reviews.order(created_at: :desc).first&.destroy!
    end

    redirect_to deck_study_session_path(@deck), notice: "Last answer undone."
  end

  private

  def set_deck
    @deck = current_user.decks.find(params[:deck_id])
  end

  def initialize_session_manager
    @session_manager = Study::SessionManager.new(@deck, current_user)
  end

  # Renders the front (question) side of a card
  # @param card [Card]
  # @return [String] HTML
  def render_card_front(card)
    renderer = Cards::TemplateRenderer.new(card)
    renderer.render_front
  end

  # Renders the back (answer) side of a card
  # @param card [Card]
  # @return [String] HTML
  def render_card_back(card)
    renderer = Cards::TemplateRenderer.new(card)
    renderer.render_back
  end
end
