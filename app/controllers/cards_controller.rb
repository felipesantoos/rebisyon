# frozen_string_literal: true

class CardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_card, only: %i[show edit update]

  # GET /cards/:id
  def show
    @note = @card.note
    @deck = @card.deck
  end

  # GET /cards/:id/edit
  def edit
  end

  # PATCH /cards/:id
  def update
    if @card.update(card_params)
      redirect_to card_path(@card), notice: t("flash.update_success", resource: Card.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # POST /cards/bulk_flag
  def bulk_flag
    cards = current_user.cards.where(id: params[:card_ids])
    flag = params[:flag].to_i
    cards.update_all(flag: flag)
    redirect_back fallback_location: notes_path, notice: "#{cards.count} card(s) flagged."
  end

  # POST /cards/bulk_suspend
  def bulk_suspend
    cards = current_user.cards.where(id: params[:card_ids])
    suspended = ActiveModel::Type::Boolean.new.cast(params[:suspended])
    cards.update_all(suspended: suspended)
    redirect_back fallback_location: notes_path, notice: "#{cards.count} card(s) updated."
  end

  # POST /cards/bulk_bury
  def bulk_bury
    cards = current_user.cards.where(id: params[:card_ids])
    buried = ActiveModel::Type::Boolean.new.cast(params[:buried])
    cards.update_all(buried: buried)
    redirect_back fallback_location: notes_path, notice: "#{cards.count} card(s) updated."
  end

  # POST /cards/bulk_reset_scheduling
  def bulk_reset_scheduling
    cards = current_user.cards.where(id: params[:card_ids])
    cards.update_all(
      state: :new,
      due: 0,
      interval: 0,
      ease: 2500,
      lapses: 0,
      reps: 0
    )
    redirect_back fallback_location: notes_path, notice: "#{cards.count} card(s) reset."
  end

  # POST /cards/bulk_set_due_date
  def bulk_set_due_date
    cards = current_user.cards.where(id: params[:card_ids])
    due = params[:due].to_i
    cards.update_all(due: due)
    redirect_back fallback_location: notes_path, notice: "#{cards.count} card(s) rescheduled."
  end

  private

  def set_card
    @card = current_user.cards.find(params[:id])
  end

  def card_params
    params.require(:card).permit(:flag, :suspended, :buried)
  end
end
