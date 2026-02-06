# frozen_string_literal: true

module Api
  module V1
    class CheckDatabaseLogsController < BaseController
      before_action :set_check_database_log, only: :show

      # GET /api/v1/check_database_logs
      def index
        result = paginate(current_user.check_database_logs.recent)
        render json: result
      end

      # GET /api/v1/check_database_logs/:id
      def show
        render json: { data: @check_database_log }
      end

      private

      def set_check_database_log
        @check_database_log = current_user.check_database_logs.find(params[:id])
      end
    end
  end
end
