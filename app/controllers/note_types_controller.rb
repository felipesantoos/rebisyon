# frozen_string_literal: true

class NoteTypesController < ApplicationController
  include Paginatable

  before_action :authenticate_user!
  before_action :set_note_type, only: %i[show edit update destroy]

  # GET /note_types
  def index
    @pagy, @note_types = paginate(current_user.note_types.ordered)
  end

  # GET /note_types/:id
  def show
  end

  # GET /note_types/new
  def new
    @note_type = current_user.note_types.build
    # Set default empty structures
    @note_type.fields_json = []
    @note_type.card_types_json = []
    @note_type.templates_json = {}
  end

  # GET /note_types/:id/edit
  def edit
  end

  # POST /note_types
  def create
    @note_type = current_user.note_types.build(note_type_params)

    if @note_type.save
      redirect_to @note_type, notice: "Note type was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /note_types/:id
  def update
    if @note_type.update(note_type_params)
      redirect_to @note_type, notice: "Note type was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /note_types/:id
  def destroy
    @note_type.soft_delete!
    redirect_to note_types_url, notice: "Note type was successfully deleted."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_note_type
    @note_type = current_user.note_types.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def note_type_params
    params.require(:note_type).permit(:name, fields_json: [], card_types_json: [], templates_json: {})
  end
end
