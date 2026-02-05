# frozen_string_literal: true

class CreateMedia < ActiveRecord::Migration[7.2]
  def change
    create_table :media, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint, index: false
      t.string :filename, null: false, limit: 255
      t.column :hash, :string, null: false, limit: 64
      t.bigint :size, null: false
      t.string :mime_type, null: false, limit: 100
      t.string :storage_path, null: false, limit: 512
      t.timestamp :deleted_at

      t.timestamps
    end

    # Indexes
    unless index_exists?(:media, :user_id)
      add_index :media, :user_id, name: "idx_media_user_id"
    end

    unless index_exists?(:media, :hash, name: "idx_media_hash")
      add_index :media, :hash, name: "idx_media_hash"
    end

    unless index_exists?(:media, [:user_id, :hash, :deleted_at], name: "unique_media_hash_per_user")
      add_index :media, [:user_id, :hash, :deleted_at], 
                unique: true, 
                name: "unique_media_hash_per_user",
                where: "deleted_at IS NULL"
    end

    # Constraints
    unless connection.select_value("SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_size_positive' AND table_name = 'media'")
      execute <<-SQL
        ALTER TABLE media
        ADD CONSTRAINT check_size_positive
        CHECK (size > 0)
      SQL
    end
  end
end
