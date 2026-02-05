# frozen_string_literal: true

module Media
  # Parses media references from note fields and creates NoteMedia associations
  #
  # Media references can be:
  # - Images: <img src="filename.jpg">
  # - Audio: [sound:filename.mp3]
  # - Video: <video src="filename.mp4"></video>
  #
  # @example
  #   parser = Media::ReferenceParser.new(note)
  #   parser.parse_and_associate
  class ReferenceParser
    attr_reader :note

    def initialize(note)
      @note = note
    end

    # Parses all fields and creates media associations
    # @return [Array<NoteMedium>] Created associations
    def parse_and_associate
      return [] unless note.note_type

      associations = []
      note.note_type.field_names.each do |field_name|
        field_value = note.fields_json[field_name.to_s] || ""
        media_filenames = extract_media_references(field_value)
        
        media_filenames.each do |filename|
          medium = find_medium_by_filename(filename)
          next unless medium

          # Create or find association
          association = note.note_media.find_or_create_by(
            medium: medium,
            field_name: field_name
          )
          associations << association unless association.new_record?
        end
      end

      associations
    end

    private

    # Extracts media filenames from field text
    # @param text [String]
    # @return [Array<String>] Array of filenames
    def extract_media_references(text)
      filenames = []

      # Extract image references: <img src="filename.jpg">
      text.scan(/<img[^>]+src=["']([^"']+)["']/i) do |match|
        filenames << match[0]
      end

      # Extract audio references: [sound:filename.mp3]
      text.scan(/\[sound:([^\]]+)\]/i) do |match|
        filenames << match[0]
      end

      # Extract video references: <video src="filename.mp4">
      text.scan(/<video[^>]+src=["']([^"']+)["']/i) do |match|
        filenames << match[0]
      end

      filenames.uniq
    end

    # Finds a medium by filename for the note's user
    # @param filename [String]
    # @return [Medium, nil]
    def find_medium_by_filename(filename)
      note.user.media.find_by(filename: filename, deleted_at: nil)
    end
  end
end
