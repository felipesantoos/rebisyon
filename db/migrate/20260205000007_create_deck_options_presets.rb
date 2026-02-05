# frozen_string_literal: true

class CreateDeckOptionsPresets < ActiveRecord::Migration[7.2]
  def change
    create_table :deck_options_presets, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint, index: false
      t.string :name, null: false, limit: 255
      t.jsonb :options_json, null: false, default: {}
      t.timestamp :deleted_at

      t.timestamps
    end

    # Unique constraint: name per user (including deleted_at for soft delete support)
    unless index_exists?(:deck_options_presets, [:user_id, :name, :deleted_at], name: "unique_preset_name_per_user")
      add_index :deck_options_presets, [:user_id, :name, :deleted_at], unique: true, name: "unique_preset_name_per_user"
    end
  end
end
