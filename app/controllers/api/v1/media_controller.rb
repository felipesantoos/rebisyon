# frozen_string_literal: true

module Api
  module V1
    class MediaController < BaseController
      before_action :set_medium, only: %i[show destroy]

      # GET /api/v1/media
      def index
        result = paginate(current_user.media.order(created_at: :desc))
        render json: result
      end

      # GET /api/v1/media/:id
      def show
        render json: { data: @medium }
      end

      # POST /api/v1/media
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

        detected_type = Marcel::MimeType.for(uploaded_file.tempfile, name: uploaded_file.original_filename)
        unless allowed_mime_types.include?(detected_type)
          render json: { error: "File type not supported" }, status: :bad_request
          return
        end

        file_hash = Medium.compute_hash(uploaded_file)
        existing_medium = current_user.media.find_by(hash: file_hash, deleted_at: nil)

        if existing_medium
          render json: { data: existing_medium }, status: :ok
          return
        end

        medium = current_user.media.build(
          filename: uploaded_file.original_filename,
          hash: file_hash,
          size: uploaded_file.size,
          mime_type: detected_type,
          storage_path: ""
        )
        medium.save!

        medium.file.attach(
          io: uploaded_file,
          filename: uploaded_file.original_filename,
          content_type: detected_type
        )

        if medium.file.attached?
          medium.update_column(:storage_path, ActiveStorage::Blob.service.path_for(medium.file.key))
        end

        render json: { data: medium }, status: :created
      end

      # DELETE /api/v1/media/:id
      def destroy
        @medium.soft_delete!
        head :no_content
      end

      private

      def set_medium
        @medium = current_user.media.find(params[:id])
      end
    end
  end
end
