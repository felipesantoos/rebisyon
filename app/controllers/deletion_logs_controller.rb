# frozen_string_literal: true

class DeletionLogsController < ApplicationController
  before_action :authenticate_user!

  def index
    @logs = helpers.mock_deletion_logs
    @filter = params[:filter] || "all"
  end

  def show
    @log = helpers.mock_deletion_log_detail
  end

  def restore
    redirect_to deletion_logs_path, notice: "Item restored successfully."
  end
end
