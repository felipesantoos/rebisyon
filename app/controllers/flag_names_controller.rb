# frozen_string_literal: true

class FlagNamesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_flag_name, only: %i[update destroy]

  # GET /flag_names
  def index
    @flag_names = current_user.flag_names.order(:flag_number)
    @flags = (1..7).map do |n|
      @flag_names.find { |fn| fn.flag_number == n } || current_user.flag_names.build(flag_number: n)
    end
  end

  # POST /flag_names
  def create
    @flag_name = current_user.flag_names.build(flag_name_params)

    if @flag_name.save
      redirect_to flag_names_path, notice: t("flash.create_success", resource: FlagName.model_name.human)
    else
      redirect_to flag_names_path, alert: @flag_name.errors.full_messages.join(", ")
    end
  end

  # PATCH /flag_names/:id
  def update
    if @flag_name.update(flag_name_params)
      redirect_to flag_names_path, notice: t("flash.update_success", resource: FlagName.model_name.human)
    else
      redirect_to flag_names_path, alert: @flag_name.errors.full_messages.join(", ")
    end
  end

  # DELETE /flag_names/:id
  def destroy
    @flag_name.destroy
    redirect_to flag_names_path, notice: t("flash.destroy_success", resource: FlagName.model_name.human)
  end

  private

  def set_flag_name
    @flag_name = current_user.flag_names.find(params[:id])
  end

  def flag_name_params
    params.require(:flag_name).permit(:flag_number, :name)
  end
end
