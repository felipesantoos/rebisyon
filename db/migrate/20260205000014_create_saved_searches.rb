# frozen_string_literal: true

class CreateSavedSearches < ActiveRecord::Migration[7.2]
  def change
    create_table :saved_searches, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint, index: false
      t.string :name, null: false, limit: 255
      t.text :search_query, null: false
      t.timestamp :deleted_at

      t.timestamps
    end

    # Unique constraint: name per user (including deleted_at for soft delete support)
    unless index_exists?(:saved_searches, [:user_id, :name, :deleted_at], name: "unique_saved_search_name_per_user")
      add_index :saved_searches, [:user_id, :name, :deleted_at], unique: true, name: "unique_saved_search_name_per_user"
    end

    # Indexes
    unless index_exists?(:saved_searches, :user_id, where: "deleted_at IS NULL")
      add_index :saved_searches, :user_id, where: "deleted_at IS NULL", name: "idx_saved_searches_user_id"
    end
  end
end
