# frozen_string_literal: true

module Api
  module V1
    class DecksController < BaseController
      before_action :set_deck, only: %i[show update destroy]

      # GET /api/v1/decks
      def index
        result = paginate(current_user.decks.ordered)
        render json: result
      end

      # GET /api/v1/decks/:id
      def show
        render json: { data: @deck }
      end

      # POST /api/v1/decks
      def create
        deck = current_user.decks.build(deck_params)
        deck.save!
        render json: { data: deck }, status: :created
      end

      # PATCH /api/v1/decks/:id
      def update
        @deck.update!(deck_params)
        render json: { data: @deck }
      end

      # DELETE /api/v1/decks/:id
      def destroy
        @deck.soft_delete!
        head :no_content
      end

      private

      def set_deck
        @deck = current_user.decks.find(params[:id])
      end

      def deck_params
        params.require(:deck).permit(:name, :parent_id, options_json: {})
      end
    end
  end
end
