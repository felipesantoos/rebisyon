# frozen_string_literal: true

class UndoHistoriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @history = helpers.mock_undo_history
    @filter = params[:filter] || "all"
  end

  def show
    @entry = helpers.mock_undo_history_detail
  end
end
