# frozen_string_literal: true

module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json

      skip_before_action :verify_authenticity_token

      rescue_from ActiveRecord::RecordNotFound do |e|
        render json: { error: "Record not found", message: e.message }, status: :not_found
      end

      rescue_from ActionController::ParameterMissing do |e|
        render json: { error: "Missing parameter", message: e.message }, status: :bad_request
      end

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          resource.track_login!
          render json: {
            message: "Logged in successfully",
            user: user_data(resource)
          }, status: :ok
        else
          render json: {
            error: "Login failed"
          }, status: :unauthorized
        end
      end

      def respond_to_on_destroy
        if current_user
          render json: {
            message: "Logged out successfully"
          }, status: :ok
        else
          render json: {
            error: "No active session"
          }, status: :unauthorized
        end
      end

      def user_data(user)
        {
          id: user.id,
          email: user.email,
          created_at: user.created_at,
          confirmed_at: user.confirmed_at
        }
      end
    end
  end
end
