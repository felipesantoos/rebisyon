# frozen_string_literal: true

module Api
  module V1
    class DeletionLogsController < BaseController
      # GET /api/v1/deletion_logs
      def index
        deletion_logs = current_user.deletion_logs
        deletion_logs = deletion_logs.where(object_type: params[:object_type]) if params[:object_type].present?
        result = paginate(deletion_logs)
        render json: result
      end
    end
  end
end
