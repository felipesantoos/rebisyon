# frozen_string_literal: true

class AddOnsController < ApplicationController
  include Paginatable

  before_action :authenticate_user!
  before_action :set_add_on, only: %i[show update destroy]

  def index
    @pagy, @add_ons = paginate(current_user.add_ons.order(:name))
  end

  def show
  end

  def new
    @add_on = current_user.add_ons.build
  end

  def create
    @add_on = current_user.add_ons.build(add_on_params)
    if @add_on.save
      redirect_to add_ons_path, notice: "Add-on installed."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @add_on.update(add_on_params)
      redirect_to add_on_path(@add_on), notice: "Add-on updated."
    else
      redirect_to add_on_path(@add_on), alert: @add_on.errors.full_messages.join(", ")
    end
  end

  def destroy
    @add_on.destroy
    redirect_to add_ons_path, notice: "Add-on removed."
  end

  private

  def set_add_on
    @add_on = current_user.add_ons.find(params[:id])
  end

  def add_on_params
    params.require(:add_on).permit(:code, :name, :version, :enabled, config_json: {})
  end
end
