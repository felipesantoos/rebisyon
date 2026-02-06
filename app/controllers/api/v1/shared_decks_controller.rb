# frozen_string_literal: true

module Api
  module V1
    class SharedDecksController < BaseController
      before_action :set_shared_deck, only: %i[show update destroy]

      # GET /api/v1/shared_decks
      def index
        shared_decks = SharedDeck.public_decks
        shared_decks = shared_decks.where(category: params[:category]) if params[:category].present?
        result = paginate(shared_decks)
        render json: result
      end

      # GET /api/v1/shared_decks/:id
      def show
        render json: { data: @shared_deck }
      end

      # POST /api/v1/shared_decks
      def create
        shared_deck = current_user.shared_decks.build(shared_deck_params)
        shared_deck.save!
        render json: { data: shared_deck }, status: :created
      end

      # PATCH /api/v1/shared_decks/:id
      def update
        @shared_deck.update!(shared_deck_params)
        render json: { data: @shared_deck }
      end

      # DELETE /api/v1/shared_decks/:id
      def destroy
        @shared_deck.soft_delete!
        head :no_content
      end

      private

      def set_shared_deck
        case action_name
        when "show"
          @shared_deck = SharedDeck.public_decks.find(params[:id])
        else
          @shared_deck = current_user.shared_decks.find(params[:id])
        end
      end

      def shared_deck_params
        params.require(:shared_deck).permit(:name, :description, :category, :package_path, :package_size, :is_public, tags: [])
      end
    end
  end
end
