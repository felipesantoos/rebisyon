# frozen_string_literal: true

class CheckDatabaseLogsController < ApplicationController
  include Paginatable

  before_action :authenticate_user!
  before_action :set_check_database_log, only: :show

  # GET /check_database_logs
  def index
    @pagy, @check_database_logs = paginate(current_user.check_database_logs.recent)
  end

  # GET /check_database_logs/:id
  def show
  end

  private

  def set_check_database_log
    @check_database_log = current_user.check_database_logs.find(params[:id])
  end
end
