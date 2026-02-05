# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController
    respond_to :html, :turbo_stream

    private

    def after_confirmation_path_for(_resource_name, resource)
      if signed_in?(resource_name)
        dashboard_path
      else
        new_user_session_path
      end
    end
  end
end
