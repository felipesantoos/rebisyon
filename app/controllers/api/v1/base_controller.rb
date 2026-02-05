# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      include Pagy::Backend

      before_action :authenticate_user!

      respond_to :json

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
      rescue_from ActionController::ParameterMissing, with: :parameter_missing

      private

      def record_not_found(exception)
        render json: {
          error: "Record not found",
          message: exception.message
        }, status: :not_found
      end

      def record_invalid(exception)
        render json: {
          error: "Validation failed",
          messages: exception.record.errors.full_messages
        }, status: :unprocessable_entity
      end

      def parameter_missing(exception)
        render json: {
          error: "Missing parameter",
          message: exception.message
        }, status: :bad_request
      end

      def authenticate_user!
        return if current_user.present?

        render json: { error: "Unauthorized" }, status: :unauthorized
      end

      def current_user
        @current_user ||= warden.authenticate(scope: :user)
      end

      def paginate(collection, items: 25)
        pagy, records = pagy(collection, items: items)
        {
          data: records,
          meta: {
            current_page: pagy.page,
            total_pages: pagy.pages,
            total_count: pagy.count,
            per_page: pagy.items
          }
        }
      end
    end
  end
end
