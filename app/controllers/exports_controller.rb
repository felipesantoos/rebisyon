# frozen_string_literal: true

class ExportsController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    redirect_to root_path, alert: "Export is not yet implemented."
  end
end
