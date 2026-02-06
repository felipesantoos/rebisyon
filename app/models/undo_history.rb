# frozen_string_literal: true

class UndoHistory < ApplicationRecord
  self.table_name = "undo_history"

  include UserScoped

  OPERATION_TYPES = %w[
    edit_note delete_note move_card change_flag
    add_tag remove_tag change_deck
  ].freeze

  validates :operation_type, presence: true, inclusion: { in: OPERATION_TYPES }
  validates :operation_data, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def summary
    data = operation_data || {}
    data["summary"] || "#{operation_type.titleize} operation"
  end

  def details
    data = operation_data || {}
    data["details"] || ""
  end
end
