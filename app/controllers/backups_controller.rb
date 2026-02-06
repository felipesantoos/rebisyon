# frozen_string_literal: true

class BackupsController < ApplicationController
  before_action :authenticate_user!

  def index
    @backups = helpers.mock_backups
    @stats = helpers.mock_backup_stats
  end

  def show
    @backup = helpers.mock_backups.find { |b| b[:id] == params[:id].to_i } || helpers.mock_backups.first
  end

  def create
    redirect_to backups_path, notice: "Backup created successfully."
  end

  def destroy
    redirect_to backups_path, notice: "Backup deleted."
  end
end
