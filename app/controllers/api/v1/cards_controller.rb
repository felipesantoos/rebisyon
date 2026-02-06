# frozen_string_literal: true

module Api
  module V1
    class CardsController < BaseController
      before_action :set_card, only: %i[show update]

      # GET /api/v1/cards
      def index
        cards = current_user.cards.includes(:note, :deck)
        cards = cards.where(deck_id: params[:deck_id]) if params[:deck_id].present?
        cards = cards.where(state: params[:state]) if params[:state].present?
        result = paginate(cards)
        render json: result
      end

      # GET /api/v1/cards/:id
      def show
        render json: { data: @card.as_json(include: %i[note deck]) }
      end

      # PATCH /api/v1/cards/:id
      def update
        @card.update!(card_params)
        render json: { data: @card }
      end

      private

      def set_card
        @card = current_user.cards.find(params[:id])
      end

      def card_params
        params.require(:card).permit(:flag, :suspended, :buried)
      end
    end
  end
end
