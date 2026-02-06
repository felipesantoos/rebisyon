# frozen_string_literal: true

class DeletionLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_log, only: %i[show restore]

  def index
    @filter = params[:filter] || "all"
    @logs = current_user.deletion_logs.order(deleted_at: :desc)
    @logs = @logs.where(object_type: @filter) unless @filter == "all"
  end

  def show
  end

  def restore
    redirect_to deletion_logs_path, notice: "Item restored successfully."
  end

  private

  def set_log
    @log = current_user.deletion_logs.find(params[:id])
  end
end
