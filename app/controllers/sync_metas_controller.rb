# frozen_string_literal: true

class SyncMetasController < ApplicationController
  before_action :authenticate_user!

  def index
    @sync_status = helpers.mock_sync_status
    @devices = helpers.mock_sync_devices
  end
end
