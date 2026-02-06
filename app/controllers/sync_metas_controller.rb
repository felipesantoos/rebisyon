# frozen_string_literal: true

class SyncMetasController < ApplicationController
  before_action :authenticate_user!

  def index
    @devices = current_user.sync_metas.order(last_sync: :desc)
    latest = @devices.first
    @sync_status = {
      connected: latest.present?,
      last_sync: latest&.last_sync&.strftime("%Y-%m-%d %H:%M") || "Never",
      server_usn: latest&.last_sync_usn || 0
    }
  end
end
