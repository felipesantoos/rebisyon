# frozen_string_literal: true

class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: %i[show edit update destroy]

  # GET /notes
  def index
    @notes = current_user.notes.includes(:note_type, :cards)
    
    # Search filtering
    if params[:search].present?
      search_term = params[:search].strip
      @notes = @notes.where(
        "fields_json::text ILIKE ? OR tags::text ILIKE ?",
        "%#{search_term}%",
        "%#{search_term}%"
      )
    end

    # Filter by deck (via cards)
    if params[:deck_id].present?
      deck_ids = [params[:deck_id].to_i]
      deck = current_user.decks.find_by(id: params[:deck_id])
      deck_ids.concat(deck.descendant_ids) if deck
      @notes = @notes.joins(:cards).where(cards: { deck_id: deck_ids }).distinct
    end

    # Filter by note type
    @notes = @notes.where(note_type_id: params[:note_type_id]) if params[:note_type_id].present?

    # Filter by tag
    if params[:tag].present?
      @notes = @notes.tagged(params[:tag])
    end

    # Filter by marked
    @notes = @notes.marked if params[:marked] == "true"

    # Sorting
    sort_column = params[:sort] || "notes.updated_at"
    sort_direction = params[:direction] == "asc" ? "asc" : "desc"
    
    # Ensure we have the necessary joins for sorting
    if sort_column.include?("note_types")
      @notes = @notes.joins(:note_type)
    end
    
    # Sanitize sort column to prevent SQL injection
    allowed_columns = ["notes.id", "notes.updated_at", "notes.created_at", "note_types.name"]
    sort_column = allowed_columns.include?(sort_column) ? sort_column : "notes.updated_at"
    
    @notes = @notes.order("#{sort_column} #{sort_direction}")

    # Pagination
    @pagy, @notes = pagy(@notes, items: params[:per_page] || 25)
  end

  # GET /notes/:id
  def show
    @cards = @note.cards.includes(:deck)
  end

  # GET /notes/new
  def new
    @note = current_user.notes.build
    @note.note_type_id = params[:note_type_id] if params[:note_type_id].present?
    @note.deck_id = params[:deck_id] if params[:deck_id].present?
    
    # Set default empty fields_json based on selected note type
    if @note.note_type
      fields_hash = {}
      @note.note_type.field_names.each do |field_name|
        fields_hash[field_name] = ""
      end
      @note.fields_json = fields_hash
    else
      @note.fields_json = {}
    end
    @note.tags = []
    
    # Load note types and decks for form
    @note_types = current_user.note_types.ordered
    @decks = current_user.decks.roots.ordered
  end

  # POST /notes
  def create
    @note = current_user.notes.build(note_params)
    
    # Set deck_id for card generation (stored temporarily)
    deck_id = params[:note][:deck_id] if params[:note][:deck_id].present?
    @note.deck_id = deck_id if deck_id.present?

    if @note.save
      # Update cards to use the specified deck if provided
      if deck_id.present?
        deck = current_user.decks.find_by(id: deck_id)
        @note.cards.update_all(deck_id: deck.id, home_deck_id: deck.id) if deck
      end
      
      redirect_to @note, notice: "Note was successfully created."
    else
      @note_types = current_user.note_types.ordered
      @decks = current_user.decks.roots.ordered
      render :new, status: :unprocessable_entity
    end
  end

  # GET /notes/:id/edit
  def edit
    @note_types = current_user.note_types.ordered
    @decks = current_user.decks.roots.ordered
  end

  # PATCH/PUT /notes/:id
  def update
    if @note.update(note_params)
      redirect_to @note, notice: "Note was successfully updated."
    else
      @note_types = current_user.note_types.ordered
      @decks = current_user.decks.roots.ordered
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /notes/:id
  def destroy
    # Log deletion before soft deleting
    DeletionLog.create!(
      user: current_user,
      object_type: "note",
      object_id: @note.id,
      object_data: {
        guid: @note.guid,
        note_type_id: @note.note_type_id,
        fields_json: @note.fields_json,
        tags: @note.tags
      }
    )
    
    @note.soft_delete!
    redirect_to notes_url, notice: "Note was successfully deleted."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_note
    @note = current_user.notes.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def note_params
    # Get note type to know which fields to permit
    note_type_id = params[:note][:note_type_id] || @note&.note_type_id
    note_type = current_user.note_types.find_by(id: note_type_id) if note_type_id
    
    # Build permitted fields based on note type
    permitted = [:note_type_id, :marked]
    
    # Add field names from note type
    if note_type
      field_names = note_type.field_names
      field_names.each do |field_name|
        permitted << field_name.to_sym
      end
    end
    
    # Permit tags as a string (will be converted to array)
    permitted << :tags
    
    # Permit fields_json as a hash (will be built from individual fields)
    params.require(:note).permit(permitted).tap do |whitelisted|
      # Convert tags from comma-separated string to array
      if whitelisted[:tags].is_a?(String)
        tags_array = whitelisted[:tags].split(",").map(&:strip).reject(&:blank?)
        whitelisted[:tags] = tags_array
      end
      
      # Build fields_json hash from individual field parameters
      if note_type
        fields_hash = {}
        note_type.field_names.each do |field_name|
          fields_hash[field_name] = whitelisted.delete(field_name.to_sym) || ""
        end
        whitelisted[:fields_json] = fields_hash
      end
    end
  end
end
