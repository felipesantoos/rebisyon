# frozen_string_literal: true

# Job to detect and clean up unused media files
#
# Unused media are files that are not referenced by any notes.
# This job should be scheduled to run periodically (e.g., weekly)
class MediaCleanupJob < ApplicationJob
  queue_as :default

  # Finds and optionally deletes unused media for a user
  # @param user_id [Integer]
  # @param dry_run [Boolean] If true, only reports unused media without deleting
  # @return [Hash] Report of unused media found/deleted
  def perform(user_id, dry_run: true)
    user = User.find(user_id)
    unused_media = find_unused_media(user)

    report = {
      user_id: user_id,
      total_media: user.media.count,
      unused_count: unused_media.count,
      unused_media: unused_media.map { |m| { id: m.id, filename: m.filename, size: m.size } },
      dry_run: dry_run
    }

    unless dry_run
      # Delete unused media
      deleted_count = 0
      unused_media.each do |medium|
        begin
          medium.soft_delete!
          deleted_count += 1
        rescue => e
          Rails.logger.error("Failed to delete media #{medium.id}: #{e.message}")
        end
      end
      report[:deleted_count] = deleted_count
    end

    report
  end

  private

  # Finds media that is not used by any notes
  # @param user [User]
  # @return [ActiveRecord::Relation<Medium>]
  def find_unused_media(user)
    user.media
        .where(deleted_at: nil)
        .left_joins(:note_media)
        .where(note_media: { id: nil })
  end
end
