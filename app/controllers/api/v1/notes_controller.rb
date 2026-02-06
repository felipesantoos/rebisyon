# frozen_string_literal: true

module Api
  module V1
    class NotesController < BaseController
      before_action :set_note, only: %i[show update destroy]

      # GET /api/v1/notes
      def index
        result = paginate(current_user.notes.includes(:note_type, :cards))
        render json: result
      end

      # GET /api/v1/notes/:id
      def show
        render json: { data: @note.as_json(include: :cards) }
      end

      # POST /api/v1/notes
      def create
        note = current_user.notes.build(note_params)
        note.save!
        render json: { data: note }, status: :created
      end

      # PATCH /api/v1/notes/:id
      def update
        @note.update!(note_params)
        render json: { data: @note }
      end

      # DELETE /api/v1/notes/:id
      def destroy
        current_user.deletion_logs.create!(
          object_type: "note",
          object_id: @note.id,
          object_data: {
            guid: @note.guid,
            note_type_id: @note.note_type_id,
            fields_json: @note.fields_json,
            tags: @note.tags
          }
        )
        @note.soft_delete!
        head :no_content
      end

      private

      def set_note
        @note = current_user.notes.find(params[:id])
      end

      def note_params
        params.require(:note).permit(:note_type_id, :deck_id, :marked, tags: [], fields_json: {})
      end
    end
  end
end
