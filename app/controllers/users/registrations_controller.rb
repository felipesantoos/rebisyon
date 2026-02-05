# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    respond_to :html, :turbo_stream

    # Override respond_with to properly handle responses and avoid ETag middleware issues
    # The issue is that Rack's ETag middleware tries to call empty? on the response body,
    # but when respond_with returns a User object, it fails. We need to ensure we always
    # render HTML or redirect, never return the object directly.
    def respond_with(resource, opts = {})
      location = opts[:location]
      
      if resource.persisted?
        # Successful registration - redirect
        respond_to do |format|
          format.html { redirect_to location }
          format.turbo_stream { redirect_to location }
        end
      else
        # Failed registration - render form with errors
        clean_up_passwords resource
        set_minimum_password_length
        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
          format.turbo_stream { render :new, status: :unprocessable_entity }
        end
      end
    end

    private

    def after_sign_up_path_for(_resource)
      dashboard_path
    end

    def after_inactive_sign_up_path_for(_resource)
      new_user_session_path
    end

    def sign_up_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end

    def account_update_params
      params.require(:user).permit(:email, :password, :password_confirmation, :current_password)
    end
  end
end
