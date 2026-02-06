# frozen_string_literal: true

module Api
  module V1
    class SyncMetaController < BaseController
      before_action :set_sync_meta, only: %i[show update destroy]

      # GET /api/v1/sync_meta
      def index
        result = paginate(current_user.sync_metas)
        render json: result
      end

      # GET /api/v1/sync_meta/:id
      def show
        render json: { data: @sync_meta }
      end

      # POST /api/v1/sync_meta
      def create
        sync_meta = current_user.sync_metas.build(sync_meta_params)
        sync_meta.save!
        render json: { data: sync_meta }, status: :created
      end

      # PATCH /api/v1/sync_meta/:id
      def update
        @sync_meta.update!(sync_meta_params)
        render json: { data: @sync_meta }
      end

      # DELETE /api/v1/sync_meta/:id
      def destroy
        @sync_meta.destroy
        head :no_content
      end

      private

      def set_sync_meta
        @sync_meta = current_user.sync_metas.find(params[:id])
      end

      def sync_meta_params
        params.require(:sync_meta).permit(:client_id, :last_sync_usn)
      end
    end
  end
end
