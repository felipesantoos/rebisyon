# frozen_string_literal: true

FactoryBot.define do
  factory :browser_config do
    user
    visible_columns { %w[note deck tags due interval ease] }
    column_widths { {} }
    sort_column { "note" }
    sort_direction { "asc" }
  end
end
