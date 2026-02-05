# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Declare supported response formats (built-in Rails method, no gem required)
  # Devise controllers use their own respond_with implementation
  respond_to :html, :turbo_stream

  # Protect from forgery
  protect_from_forgery with: :exception

  # Before actions
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  # Helper methods accessible in views
  helper_method :current_user_preference

  private

  # Configure permitted parameters for Devise
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[])
  end

  # Set locale from user preferences or browser
  def set_locale
    I18n.locale = user_locale || I18n.default_locale
  end

  def user_locale
    return unless user_signed_in?

    current_user.user_preference&.language&.to_sym
  end

  # Returns current user's preference or nil
  def current_user_preference
    return unless user_signed_in?

    current_user.user_preference
  end
end
