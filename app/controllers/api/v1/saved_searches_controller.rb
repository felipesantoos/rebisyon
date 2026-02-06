# frozen_string_literal: true

module Api
  module V1
    class SavedSearchesController < BaseController
      before_action :set_saved_search, only: %i[update destroy]

      # GET /api/v1/saved_searches
      def index
        result = paginate(current_user.saved_searches)
        render json: result
      end

      # POST /api/v1/saved_searches
      def create
        saved_search = current_user.saved_searches.build(saved_search_params)
        saved_search.save!
        render json: { data: saved_search }, status: :created
      end

      # PATCH /api/v1/saved_searches/:id
      def update
        @saved_search.update!(saved_search_params)
        render json: { data: @saved_search }
      end

      # DELETE /api/v1/saved_searches/:id
      def destroy
        @saved_search.soft_delete!
        head :no_content
      end

      private

      def set_saved_search
        @saved_search = current_user.saved_searches.find(params[:id])
      end

      def saved_search_params
        params.require(:saved_search).permit(:name, :search_query)
      end
    end
  end
end
