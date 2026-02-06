# frozen_string_literal: true

module Api
  module V1
    class UndoHistoriesController < BaseController
      # GET /api/v1/undo_histories
      def index
        result = paginate(current_user.undo_histories.recent)
        render json: result
      end
    end
  end
end
