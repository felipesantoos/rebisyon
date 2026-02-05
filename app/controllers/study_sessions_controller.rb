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

  # POST /decks/:deck_id/study/undo
  def undo
    # TODO: Implement undo functionality (Phase 4+)
    # This would require storing undo history
    redirect_to deck_study_path(@deck), alert: "Undo not yet implemented."
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
