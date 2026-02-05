# frozen_string_literal: true

class CreateDecks < ActiveRecord::Migration[7.2]
  def change
    create_table :decks, if_not_exists: true do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint, index: false
      t.string :name, null: false, limit: 255
      t.references :parent, null: true, foreign_key: { to_table: :decks }, type: :bigint, index: false
      t.jsonb :options_json, null: false, default: {}
      t.timestamp :deleted_at

      t.timestamps
    end

    # Indexes (with WHERE clauses for soft delete support)
    # Check if index exists before creating to avoid errors
    unless index_exists?(:decks, :user_id, where: "deleted_at IS NULL")
      add_index :decks, :user_id, where: "deleted_at IS NULL"
    end

    unless index_exists?(:decks, :parent_id, where: "deleted_at IS NULL")
      add_index :decks, :parent_id, where: "deleted_at IS NULL"
    end

    unless index_exists?(:decks, :name, where: "deleted_at IS NULL")
      add_index :decks, :name, where: "deleted_at IS NULL"
    end

    unless index_exists?(:decks, [:user_id, :parent_id], where: "deleted_at IS NULL")
      add_index :decks, [:user_id, :parent_id], where: "deleted_at IS NULL"
    end

    unless index_exists?(:decks, [:user_id, :updated_at], where: "deleted_at IS NULL")
      add_index :decks, [:user_id, :updated_at], where: "deleted_at IS NULL"
    end

    # Partial unique indexes for name uniqueness per hierarchy level
    unless index_exists?(:decks, [:user_id, :name], name: "idx_decks_unique_name_root")
      add_index :decks, [:user_id, :name], unique: true, where: "parent_id IS NULL AND deleted_at IS NULL", name: "idx_decks_unique_name_root"
    end

    unless index_exists?(:decks, [:user_id, :name, :parent_id], name: "idx_decks_unique_name_child")
      add_index :decks, [:user_id, :name, :parent_id], unique: true, where: "parent_id IS NOT NULL AND deleted_at IS NULL", name: "idx_decks_unique_name_child"
    end
  end
end
