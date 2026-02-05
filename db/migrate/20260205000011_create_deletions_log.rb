# frozen_string_literal: true

class CreateDeletionsLog < ActiveRecord::Migration[7.2]
  def change
    create_table :deletions_log, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint, index: false
      t.string :object_type, null: false, limit: 50
      t.bigint :object_id, null: false
      t.jsonb :object_data
      t.timestamp :deleted_at, null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.timestamps
    end

    # Constraint
    unless connection.select_value("SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_object_type' AND table_name = 'deletions_log'")
      execute <<-SQL
        ALTER TABLE deletions_log
        ADD CONSTRAINT check_object_type
        CHECK (object_type IN ('note', 'card', 'deck', 'note_type'))
      SQL
    end

    # Indexes
    unless index_exists?(:deletions_log, :user_id)
      add_index :deletions_log, :user_id, name: "idx_deletions_log_user_id"
    end

    unless index_exists?(:deletions_log, [:object_type, :object_id])
      add_index :deletions_log, [:object_type, :object_id], name: "idx_deletions_log_object"
    end

    unless index_exists?(:deletions_log, :deleted_at)
      add_index :deletions_log, :deleted_at, name: "idx_deletions_log_deleted_at"
    end
  end
end
