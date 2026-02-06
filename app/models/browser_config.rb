# frozen_string_literal: true

class BrowserConfig < ApplicationRecord
  self.table_name = "browser_config"

  include UserScoped

  # Validations
  validates :visible_columns, presence: true
  validates :sort_direction, inclusion: { in: %w[asc desc] }

  # Default values
  attribute :visible_columns, :text, array: true, default: -> { ["note", "deck", "tags", "due", "interval", "ease"] }
  attribute :column_widths, :jsonb, default: -> { {} }
  attribute :sort_direction, :string, default: "asc"
end
