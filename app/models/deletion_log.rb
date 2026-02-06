# frozen_string_literal: true

class DeletionLog < ApplicationRecord
  self.table_name = "deletions_log"

  include UserScoped

  # Validations
  validates :object_type, presence: true, inclusion: { in: %w[note card deck note_type] }
  validates :object_id, presence: true
  validates :deleted_at, presence: true

  def summary
    data = object_data || {}
    case object_type
    when "note"
      name = data["fields"]&.values&.first || "Unknown"
      "Note: #{name} (#{data['note_type'] || 'Unknown'})"
    when "card"
      "Card ##{object_id}#{data['deck'] ? " from deck #{data['deck']}" : ""}"
    when "deck"
      "Deck: #{data['name'] || "Unknown"}"
    when "note_type"
      "Note Type: #{data['name'] || "Unknown"}"
    else
      "#{object_type.titleize} ##{object_id}"
    end
  end
end
