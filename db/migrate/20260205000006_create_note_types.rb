# frozen_string_literal: true

class CreateNoteTypes < ActiveRecord::Migration[7.2]
  def change
    create_table :note_types, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint, index: false
      t.string :name, null: false, limit: 255
      t.jsonb :fields_json, null: false, default: []
      t.jsonb :card_types_json, null: false, default: []
      t.jsonb :templates_json, null: false, default: {}
      t.timestamp :deleted_at

      t.timestamps
    end

    # Unique constraint: name per user (including deleted_at for soft delete support)
    unless index_exists?(:note_types, [:user_id, :name, :deleted_at], name: "unique_note_type_name_per_user")
      add_index :note_types, [:user_id, :name, :deleted_at], unique: true, name: "unique_note_type_name_per_user"
    end

    # Indexes
    unless index_exists?(:note_types, :user_id, where: "deleted_at IS NULL")
      add_index :note_types, :user_id, where: "deleted_at IS NULL"
    end

    unless index_exists?(:note_types, :name, where: "deleted_at IS NULL")
      add_index :note_types, :name, where: "deleted_at IS NULL"
    end
  end
end
