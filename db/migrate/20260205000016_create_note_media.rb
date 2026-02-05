# frozen_string_literal: true

class CreateNoteMedia < ActiveRecord::Migration[7.2]
  def change
    create_table :note_media, if_not_exists: true, id: false do |t|
      t.references :note, null: false, foreign_key: true, type: :bigint, index: false
      t.references :media, null: false, foreign_key: true, type: :bigint, index: false
      t.string :field_name, limit: 100
      t.timestamps
    end

    # Composite primary key
    unless connection.select_value("SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'note_media_pkey' AND table_name = 'note_media'")
      execute <<-SQL
        ALTER TABLE note_media
        ADD PRIMARY KEY (note_id, media_id)
      SQL
    end

    # Unique constraint for note, media, and field_name combination
    unless index_exists?(:note_media, [:note_id, :media_id, :field_name], name: "unique_note_media_field")
      add_index :note_media, [:note_id, :media_id, :field_name], 
                unique: true, 
                name: "unique_note_media_field"
    end

    # Indexes for efficient lookups
    unless index_exists?(:note_media, :note_id)
      add_index :note_media, :note_id, name: "idx_note_media_note_id"
    end

    unless index_exists?(:note_media, :media_id)
      add_index :note_media, :media_id, name: "idx_note_media_media_id"
    end
  end
end
