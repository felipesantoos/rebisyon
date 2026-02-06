# frozen_string_literal: true

class ImportsController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    redirect_to root_path, notice: "Import started."
  end
end
