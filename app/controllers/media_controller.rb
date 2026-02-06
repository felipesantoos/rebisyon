# frozen_string_literal: true

class MediaController < ApplicationController
  include Pagy::Backend

  before_action :authenticate_user!
  before_action :set_medium, only: %i[show destroy]

  def index
    @filter = params[:filter] || "all"
    media = current_user.media.where(deleted_at: nil).order(created_at: :desc)
    media = case @filter
            when "images" then media.images
            when "audio" then media.audio
            when "video" then media.video
            when "unused" then media.left_joins(:note_media).where(note_media: { id: nil })
            else media
            end
    @pagy, @media_items = pagy(media, items: 25)
  end

  def check
    redirect_to media_path, notice: "Media check completed."
  end

  def show
    if @medium.file.attached?
      redirect_to rails_blob_path(@medium.file, disposition: "inline")
    else
      send_file @medium.storage_path, type: @medium.mime_type, disposition: "inline"
    end
  end

  def create
    uploaded_file = params[:file]
    unless uploaded_file
      render json: { error: "No file provided" }, status: :bad_request
      return
    end

    max_size = 100 * 1024 * 1024
    if uploaded_file.size > max_size
      render json: { error: "File size exceeds 100MB limit" }, status: :bad_request
      return
    end

    allowed_mime_types = [
      "image/jpeg", "image/png", "image/gif", "image/webp",
      "audio/mpeg", "audio/ogg", "audio/wav",
      "video/mp4", "video/webm"
    ]
    unless allowed_mime_types.include?(uploaded_file.content_type)
      render json: { error: "File type not supported" }, status: :bad_request
      return
    end

    file_hash = Medium.compute_hash(uploaded_file)
    existing_medium = current_user.media.find_by(hash: file_hash, deleted_at: nil)

    if existing_medium
      render json: { id: existing_medium.id, filename: existing_medium.filename, url: medium_path(existing_medium), mime_type: existing_medium.mime_type }, status: :ok
      return
    end

    @medium = current_user.media.build(
      filename: uploaded_file.original_filename,
      hash: file_hash,
      size: uploaded_file.size,
      mime_type: uploaded_file.content_type,
      storage_path: ""
    )

    if @medium.save
      @medium.file.attach(io: uploaded_file, filename: uploaded_file.original_filename, content_type: uploaded_file.content_type)
      if @medium.file.attached?
        @medium.update_column(:storage_path, ActiveStorage::Blob.service.path_for(@medium.file.key))
      end
      render json: { id: @medium.id, filename: @medium.filename, url: medium_path(@medium), mime_type: @medium.mime_type }, status: :created
    else
      render json: { errors: @medium.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
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
