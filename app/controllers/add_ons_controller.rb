# frozen_string_literal: true

class AddOnsController < ApplicationController
  before_action :authenticate_user!

  def index
    @add_ons = helpers.mock_add_ons
  end

  def show
    @add_on = helpers.mock_add_on_detail
  end

  def new; end

  def create
    redirect_to add_ons_path, notice: "Add-on installed."
  end

  def update
    redirect_to add_ons_path, notice: "Add-on updated."
  end

  def destroy
    redirect_to add_ons_path, notice: "Add-on removed."
  end
end
