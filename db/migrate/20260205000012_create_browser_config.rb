# frozen_string_literal: true

class CreateBrowserConfig < ActiveRecord::Migration[7.2]
  def change
    create_table :browser_config, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint, index: false
      t.text :visible_columns, array: true, default: ["note", "deck", "tags", "due", "interval", "ease"]
      t.jsonb :column_widths, null: false, default: {}
      t.string :sort_column, limit: 100
      t.string :sort_direction, null: false, default: "asc", limit: 10

      t.timestamps
    end

    # Unique index on user_id (one config per user)
    unless index_exists?(:browser_config, :user_id, unique: true)
      add_index :browser_config, :user_id, unique: true, name: "index_browser_config_on_user_id"
    end
  end
end
