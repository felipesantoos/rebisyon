# frozen_string_literal: true

class DeckOptionsPresetsController < ApplicationController
  include Paginatable

  before_action :authenticate_user!
  before_action :set_preset, only: %i[show edit update destroy]

  # GET /deck_options_presets
  def index
    @pagy, @presets = paginate(current_user.deck_options_presets.ordered)
  end

  # GET /deck_options_presets/:id
  def show
  end

  # GET /deck_options_presets/new
  def new
    @preset = current_user.deck_options_presets.build
    @preset.options_json = {}
  end

  # GET /deck_options_presets/:id/edit
  def edit
  end

  # POST /deck_options_presets
  def create
    @preset = current_user.deck_options_presets.build(preset_params)

    if @preset.save
      redirect_to @preset, notice: "Preset was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /deck_options_presets/:id
  def update
    if @preset.update(preset_params)
      redirect_to @preset, notice: "Preset was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /deck_options_presets/:id
  def destroy
    @preset.soft_delete!
    redirect_to deck_options_presets_url, notice: "Preset was successfully deleted."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_preset
    @preset = current_user.deck_options_presets.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def preset_params
    params.require(:deck_options_preset).permit(:name, options_json: {})
  end
end
