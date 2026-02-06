# frozen_string_literal: true

class BackupsController < ApplicationController
  include Paginatable

  before_action :authenticate_user!
  before_action :set_backup, only: %i[show destroy]

  def index
    @filter = params[:type] || "all"
    backups = current_user.backups.recent
    backups = backups.where(backup_type: @filter) unless @filter == "all"
    @pagy, @backups = paginate(backups)
    @stats = {
      total_backups: current_user.backups.count,
      total_size: number_to_human_size(current_user.backups.sum(:size)),
      last_backup: current_user.backups.recent.first&.created_at&.strftime("%Y-%m-%d %H:%M") || "Never"
    }
  end

  def show
  end

  def create
    redirect_to backups_path, alert: "Backup creation is not yet implemented."
  end

  def destroy
    @backup.destroy
    redirect_to backups_path, notice: "Backup deleted."
  end

  private

  def set_backup
    @backup = current_user.backups.find(params[:id])
  end
end
