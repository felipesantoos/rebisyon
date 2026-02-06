# frozen_string_literal: true

module Api
  module V1
    class NoteTypesController < BaseController
      before_action :set_note_type, only: %i[show update destroy]

      # GET /api/v1/note_types
      def index
        result = paginate(current_user.note_types.ordered)
        render json: result
      end

      # GET /api/v1/note_types/:id
      def show
        render json: { data: @note_type }
      end

      # POST /api/v1/note_types
      def create
        note_type = current_user.note_types.build(note_type_params)
        note_type.save!
        render json: { data: note_type }, status: :created
      end

      # PATCH /api/v1/note_types/:id
      def update
        @note_type.update!(note_type_params)
        render json: { data: @note_type }
      end

      # DELETE /api/v1/note_types/:id
      def destroy
        @note_type.soft_delete!
        head :no_content
      end

      private

      def set_note_type
        @note_type = current_user.note_types.find(params[:id])
      end

      def note_type_params
        params.require(:note_type).permit(:name, fields_json: [], card_types_json: [], templates_json: {})
      end
    end
  end
end
