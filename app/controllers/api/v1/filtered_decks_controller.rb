# frozen_string_literal: true

module Api
  module V1
    class FilteredDecksController < BaseController
      before_action :set_filtered_deck, only: %i[show update destroy]

      # GET /api/v1/filtered_decks
      def index
        result = paginate(current_user.filtered_decks)
        render json: result
      end

      # GET /api/v1/filtered_decks/:id
      def show
        render json: { data: @filtered_deck }
      end

      # POST /api/v1/filtered_decks
      def create
        filtered_deck = current_user.filtered_decks.build(filtered_deck_params)
        filtered_deck.save!
        render json: { data: filtered_deck }, status: :created
      end

      # PATCH /api/v1/filtered_decks/:id
      def update
        @filtered_deck.update!(filtered_deck_params)
        render json: { data: @filtered_deck }
      end

      # DELETE /api/v1/filtered_decks/:id
      def destroy
        @filtered_deck.soft_delete!
        head :no_content
      end

      private

      def set_filtered_deck
        @filtered_deck = current_user.filtered_decks.find(params[:id])
      end

      def filtered_deck_params
        params.require(:filtered_deck).permit(:name, :search_filter, :second_filter, :limit_cards, :order_by, :reschedule)
      end
    end
  end
end
