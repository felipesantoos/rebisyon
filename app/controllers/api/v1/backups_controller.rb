# frozen_string_literal: true

module Api
  module V1
    class BackupsController < BaseController
      before_action :set_backup, only: %i[show destroy]

      # GET /api/v1/backups
      def index
        result = paginate(current_user.backups)
        render json: result
      end

      # GET /api/v1/backups/:id
      def show
        render json: { data: @backup }
      end

      # POST /api/v1/backups
      def create
        backup = current_user.backups.build(backup_params)
        backup.save!
        render json: { data: backup }, status: :created
      end

      # DELETE /api/v1/backups/:id
      def destroy
        @backup.destroy
        head :no_content
      end

      private

      def set_backup
        @backup = current_user.backups.find(params[:id])
      end

      def backup_params
        params.require(:backup).permit(:filename, :backup_type)
      end
    end
  end
end
