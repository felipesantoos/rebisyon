# frozen_string_literal: true

class CreateFlagNames < ActiveRecord::Migration[7.2]
  def change
    create_table :flag_names, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint, index: false
      t.integer :flag_number, null: false, limit: 2
      t.string :name, null: false, limit: 50

      t.timestamps
    end

    # Constraints
    unless connection.select_value("SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_flag_number' AND table_name = 'flag_names'")
      execute <<-SQL
        ALTER TABLE flag_names
        ADD CONSTRAINT check_flag_number
        CHECK (flag_number >= 1 AND flag_number <= 7)
      SQL
    end

    # Unique constraint: one flag per user
    unless index_exists?(:flag_names, [:user_id, :flag_number], name: "unique_flag_per_user")
      add_index :flag_names, [:user_id, :flag_number], unique: true, name: "unique_flag_per_user"
    end

    # Indexes
    unless index_exists?(:flag_names, :user_id)
      add_index :flag_names, :user_id, name: "idx_flag_names_user_id"
    end
  end
end
