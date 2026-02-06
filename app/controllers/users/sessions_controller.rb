# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    respond_to :html, :turbo_stream

    # POST /users/sign_in
    def create
      self.resource = warden.authenticate!(auth_options)
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      resource.track_login!
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    end

    # Override respond_with to properly handle responses and avoid ETag middleware issues
    def respond_with(resource, opts = {})
      location = opts[:location]
      
      if location
        # Redirect after successful sign in
        respond_to do |format|
          format.html { redirect_to location }
          format.turbo_stream { redirect_to location }
        end
      else
        # Render the sign in form (for new action or failed sign in)
        # Use :unprocessable_entity so Turbo replaces the page content
        render :new, status: :unprocessable_entity
      end
    end

    private

    def after_sign_in_path_for(_resource)
      dashboard_path
    end

    def after_sign_out_path_for(_resource)
      new_user_session_path
    end
  end
end
