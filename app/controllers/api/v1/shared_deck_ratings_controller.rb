# frozen_string_literal: true

module Api
  module V1
    class SharedDeckRatingsController < BaseController
      before_action :set_shared_deck, only: %i[index create]
      before_action :set_rating, only: %i[update destroy]

      # GET /api/v1/shared_decks/:shared_deck_id/ratings
      def index
        result = paginate(@shared_deck.shared_deck_ratings)
        render json: result
      end

      # POST /api/v1/shared_decks/:shared_deck_id/ratings
      def create
        rating = current_user.shared_deck_ratings.build(rating_params)
        rating.shared_deck = @shared_deck
        rating.save!
        render json: { data: rating }, status: :created
      end

      # PATCH /api/v1/shared_decks/:shared_deck_id/ratings/:id
      def update
        @rating.update!(rating_params)
        render json: { data: @rating }
      end

      # DELETE /api/v1/shared_decks/:shared_deck_id/ratings/:id
      def destroy
        @rating.destroy
        head :no_content
      end

      private

      def set_shared_deck
        @shared_deck = SharedDeck.find(params[:shared_deck_id])
      end

      def set_rating
        @rating = current_user.shared_deck_ratings.find(params[:id])
      end

      def rating_params
        params.require(:shared_deck_rating).permit(:rating, :comment)
      end
    end
  end
end
