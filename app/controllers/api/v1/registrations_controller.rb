# frozen_string_literal: true

module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json

      skip_before_action :verify_authenticity_token

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: {
            message: "Account created successfully. Please check your email for confirmation.",
            user: user_data(resource)
          }, status: :created
        else
          render json: {
            error: "Registration failed",
            messages: resource.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end

      def user_data(user)
        {
          id: user.id,
          email: user.email,
          created_at: user.created_at
        }
      end
    end
  end
end
