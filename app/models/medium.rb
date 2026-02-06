# frozen_string_literal: true

class Medium < ApplicationRecord
  # Allow the 'hash' column despite conflicting with Object#hash
  class << self
    def instance_method_already_implemented?(method_name)
      return true if method_name == "hash"
      super
    end
  end

  include SoftDeletable
  include UserScoped

  # Associations
  has_many :note_media, foreign_key: :media_id, dependent: :destroy
  has_many :notes, through: :note_media

  # Active Storage attachment
  has_one_attached :file

  # Validations
  validates :filename, presence: true, length: { maximum: 255 }
  validates :size, presence: true, numericality: { greater_than: 0 }
  validates :mime_type, presence: true, length: { maximum: 100 }
  validates :storage_path, presence: true, length: { maximum: 512 }
  validate :hash_column_validations

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

  private

  def hash_column_validations
    h = hash_value
    if h.blank?
      errors.add(:hash, :blank)
    elsif h.length != 64
      errors.add(:hash, :wrong_length, count: 64)
    elsif self.class.unscoped.where(user_id: user_id, deleted_at: nil).where.not(id: id).exists?(["\"hash\" = ?", h])
      errors.add(:hash, :taken)
    end
  end
end
