# frozen_string_literal: true

class Medium < ApplicationRecord
  include SoftDeletable
  include UserScoped

  # Associations
  has_many :note_media, dependent: :destroy
  has_many :notes, through: :note_media

  # Active Storage attachment
  has_one_attached :file

  # Validations
  validates :filename, presence: true, length: { maximum: 255 }
  validates :hash, presence: true, length: { is: 64 }, uniqueness: { scope: [:user_id, :deleted_at], conditions: -> { where(deleted_at: nil) } }
  validates :size, presence: true, numericality: { greater_than: 0 }
  validates :mime_type, presence: true, length: { maximum: 100 }
  validates :storage_path, presence: true, length: { maximum: 512 }

  # Accessor for hash column (hash is a reserved method in Ruby)
  def hash_value
    read_attribute(:hash)
  end

  def hash_value=(value)
    write_attribute(:hash, value)
  end

  # Scopes
  scope :by_mime_type, ->(type) { where(mime_type: type) }
  scope :images, -> { where(mime_type: ["image/jpeg", "image/png", "image/gif", "image/webp"]) }
  scope :audio, -> { where(mime_type: ["audio/mpeg", "audio/ogg", "audio/wav"]) }
  scope :video, -> { where(mime_type: ["video/mp4", "video/webm"]) }

  # Computes SHA-256 hash of a file
  # @param file [ActionDispatch::Http::UploadedFile, File]
  # @return [String] Hex-encoded SHA-256 hash
  def self.compute_hash(file)
    require "digest/sha2"
    file_path = file.respond_to?(:path) ? file.path : file.to_path
    Digest::SHA256.file(file_path).hexdigest
  end

  # Checks if this media is used by any notes
  # @return [Boolean]
  def used?
    note_media.exists?
  end

  # Gets the file extension
  # @return [String, nil]
  def extension
    return nil unless filename.include?(".")

    filename.split(".").last.downcase
  end

  # Checks if this is an image
  # @return [Boolean]
  def image?
    mime_type&.start_with?("image/")
  end

  # Checks if this is audio
  # @return [Boolean]
  def audio?
    mime_type&.start_with?("audio/")
  end

  # Checks if this is video
  # @return [Boolean]
  def video?
    mime_type&.start_with?("video/")
  end
end
