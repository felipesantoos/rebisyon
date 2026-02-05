# frozen_string_literal: true

class MediaController < ApplicationController
  before_action :authenticate_user!
  before_action :set_medium, only: %i[show destroy]

  # GET /media
  def index
    @media = current_user.media.includes(:notes).order(created_at: :desc)
    @media = @media.page(params[:page]) if defined?(Kaminari)
  end

  # GET /media/:id
  def show
    # Serve the media file
    if @medium.file.attached?
      redirect_to rails_blob_path(@medium.file, disposition: "inline")
    else
      # Fallback to storage_path if Active Storage not configured
      send_file @medium.storage_path, type: @medium.mime_type, disposition: "inline"
    end
  end

  # POST /media
  def create
    uploaded_file = params[:file]
    
    unless uploaded_file
      render json: { error: "No file provided" }, status: :bad_request
      return
    end

    # Validate file size (max 100MB)
    max_size = 100 * 1024 * 1024 # 100MB
    if uploaded_file.size > max_size
      render json: { error: "File size exceeds 100MB limit" }, status: :bad_request
      return
    end

    # Validate file type
    allowed_mime_types = [
      "image/jpeg", "image/png", "image/gif", "image/webp",
      "audio/mpeg", "audio/ogg", "audio/wav",
      "video/mp4", "video/webm"
    ]
    
    unless allowed_mime_types.include?(uploaded_file.content_type)
      render json: { error: "File type not supported" }, status: :bad_request
      return
    end

    # Compute SHA-256 hash for deduplication
    file_hash = Medium.compute_hash(uploaded_file)

    # Check if media with same hash already exists for this user
    existing_medium = current_user.media.find_by(hash: file_hash, deleted_at: nil)

    if existing_medium
      # Return existing media
      render json: {
        id: existing_medium.id,
        filename: existing_medium.filename,
        url: medium_path(existing_medium),
        mime_type: existing_medium.mime_type
      }, status: :ok
      return
    end

    # Create new media record
    @medium = current_user.media.build(
      filename: uploaded_file.original_filename,
      hash: file_hash,
      size: uploaded_file.size,
      mime_type: uploaded_file.content_type,
      storage_path: "" # Will be set by Active Storage
    )

    if @medium.save
      # Attach file to Active Storage
      @medium.file.attach(
        io: uploaded_file,
        filename: uploaded_file.original_filename,
        content_type: uploaded_file.content_type
      )

      # Update storage_path with Active Storage path
      if @medium.file.attached?
        @medium.update_column(:storage_path, ActiveStorage::Blob.service.path_for(@medium.file.key))
      end

      render json: {
        id: @medium.id,
        filename: @medium.filename,
        url: medium_path(@medium),
        mime_type: @medium.mime_type
      }, status: :created
    else
      render json: { errors: @medium.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /media/:id
  def destroy
    # Only allow deletion if media is not used
    if @medium.used?
      redirect_to media_index_path, alert: "Cannot delete media that is in use."
      return
    end

    @medium.soft_delete!
    redirect_to media_index_path, notice: "Media was successfully deleted."
  end

  private

  def set_medium
    @medium = current_user.media.find(params[:id])
  end
end
