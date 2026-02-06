# frozen_string_literal: true

class UndoHistoriesController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!
  before_action :set_entry, only: :show

  def index
    @filter = params[:filter] || "all"
    entries = current_user.undo_histories.recent
    entries = entries.where(operation_type: @filter) unless @filter == "all"
    @pagy, @history = pagy(entries, items: 25)
  end

  def show
  end

  private

  def set_entry
    @entry = current_user.undo_histories.find(params[:id])
  end
end
