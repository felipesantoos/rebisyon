# frozen_string_literal: true

# Provides methods to verify resource ownership.
#
# When included, adds methods to check if a record belongs to the current user.
#
# @example
#   class DecksController < ApplicationController
#     include OwnershipVerifiable
#
#     before_action :verify_ownership, only: %i[show edit update destroy]
#
#     private
#
#     def set_deck
#       @deck = Deck.find(params[:id])
#     end
#
#     def resource
#       @deck
#     end
#   end
module OwnershipVerifiable
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  end

  private

  # Verifies that the current resource belongs to the current user
  def verify_ownership
    return if resource_belongs_to_user?

    respond_to do |format|
      format.html { redirect_to root_path, alert: t("errors.not_authorized") }
      format.turbo_stream { redirect_to root_path, alert: t("errors.not_authorized") }
      format.json { render json: { error: "Not authorized" }, status: :forbidden }
    end
  end

  # Checks if the resource belongs to the current user
  # Override this method in controllers if needed
  def resource_belongs_to_user?
    resource.user_id == current_user.id
  end

  # Returns the resource to check ownership for
  # Must be overridden in the including controller
  def resource
    raise NotImplementedError, "Subclass must implement #resource"
  end

  def record_not_found
    respond_to do |format|
      format.html { redirect_to root_path, alert: t("errors.record_not_found") }
      format.turbo_stream { redirect_to root_path, alert: t("errors.record_not_found") }
      format.json { render json: { error: "Record not found" }, status: :not_found }
    end
  end
end
