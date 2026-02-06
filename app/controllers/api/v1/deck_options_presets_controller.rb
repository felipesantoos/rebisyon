# frozen_string_literal: true

module Api
  module V1
    class DeckOptionsPresetsController < BaseController
      before_action :set_deck_options_preset, only: %i[show update destroy]

      # GET /api/v1/deck_options_presets
      def index
        result = paginate(current_user.deck_options_presets)
        render json: result
      end

      # GET /api/v1/deck_options_presets/:id
      def show
        render json: { data: @deck_options_preset }
      end

      # POST /api/v1/deck_options_presets
      def create
        deck_options_preset = current_user.deck_options_presets.build(deck_options_preset_params)
        deck_options_preset.save!
        render json: { data: deck_options_preset }, status: :created
      end

      # PATCH /api/v1/deck_options_presets/:id
      def update
        @deck_options_preset.update!(deck_options_preset_params)
        render json: { data: @deck_options_preset }
      end

      # DELETE /api/v1/deck_options_presets/:id
      def destroy
        @deck_options_preset.soft_delete!
        head :no_content
      end

      private

      def set_deck_options_preset
        @deck_options_preset = current_user.deck_options_presets.find(params[:id])
      end

      def deck_options_preset_params
        params.require(:deck_options_preset).permit(:name, options_json: {})
      end
    end
  end
end
