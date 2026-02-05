# frozen_string_literal: true

class CreateNotes < ActiveRecord::Migration[7.2]
  def change
    create_table :notes, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint, index: false
      t.string :guid, null: false, limit: 36
      t.references :note_type, null: false, foreign_key: true, type: :bigint, index: false
      t.jsonb :fields_json, null: false, default: {}
      t.text :tags, array: true, default: []
      t.boolean :marked, null: false, default: false
      t.timestamp :deleted_at

      t.timestamps
    end

    # GUID format constraint
    unless connection.select_value("SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_guid_format' AND table_name = 'notes'")
      execute <<-SQL
        ALTER TABLE notes
        ADD CONSTRAINT check_guid_format
        CHECK (guid ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
      SQL
    end

    # Indexes
    unless index_exists?(:notes, :user_id, where: "deleted_at IS NULL")
      add_index :notes, :user_id, where: "deleted_at IS NULL", name: "idx_notes_user_id"
    end

    unless index_exists?(:notes, :note_type_id, where: "deleted_at IS NULL")
      add_index :notes, :note_type_id, where: "deleted_at IS NULL", name: "idx_notes_note_type_id"
    end

    unless index_exists?(:notes, :guid)
      add_index :notes, :guid, name: "idx_notes_guid"
    end

    unless index_exists?(:notes, :marked, where: "deleted_at IS NULL")
      add_index :notes, :marked, where: "deleted_at IS NULL", name: "idx_notes_marked"
    end

    # GIN index for tags array
    unless index_exists?(:notes, :tags, name: "idx_notes_tags")
      execute <<-SQL
        CREATE INDEX idx_notes_tags ON notes USING GIN(tags) WHERE deleted_at IS NULL
      SQL
    end

    unless index_exists?(:notes, :created_at, where: "deleted_at IS NULL")
      add_index :notes, :created_at, where: "deleted_at IS NULL", name: "idx_notes_created_at"
    end

    unless index_exists?(:notes, :updated_at, where: "deleted_at IS NULL")
      add_index :notes, :updated_at, where: "deleted_at IS NULL", name: "idx_notes_updated_at"
    end

    # Full-text search index on fields_json
    unless connection.select_value("SELECT 1 FROM pg_indexes WHERE indexname = 'idx_notes_fields_fts' AND tablename = 'notes'")
      execute <<-SQL
        CREATE INDEX idx_notes_fields_fts ON notes USING GIN(to_tsvector('portuguese', fields_json::text)) WHERE deleted_at IS NULL
      SQL
    end

    unless index_exists?(:notes, [:user_id, :updated_at], where: "deleted_at IS NULL")
      add_index :notes, [:user_id, :updated_at], where: "deleted_at IS NULL", name: "idx_notes_sync"
    end

    unless index_exists?(:notes, [:user_id, :note_type_id], where: "deleted_at IS NULL")
      add_index :notes, [:user_id, :note_type_id], where: "deleted_at IS NULL", name: "idx_notes_active"
    end

    # Partial unique index on guid (only for non-deleted notes)
    unless connection.select_value("SELECT 1 FROM pg_indexes WHERE indexname = 'notes_guid_key' AND tablename = 'notes'")
      execute <<-SQL
        CREATE UNIQUE INDEX notes_guid_key ON notes(guid) WHERE deleted_at IS NULL
      SQL
    end
  end
end
