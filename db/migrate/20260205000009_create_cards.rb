# frozen_string_literal: true

class CreateCards < ActiveRecord::Migration[7.2]
  def change
    create_table :cards, if_not_exists: true do |t|
      t.references :note, null: false, foreign_key: true, type: :bigint, index: false
      t.integer :card_type_id, null: false, default: 0
      t.references :deck, null: false, foreign_key: true, type: :bigint, index: false
      t.references :home_deck, null: true, foreign_key: { to_table: :decks }, type: :bigint, index: false
      t.bigint :due, null: false, default: 0
      t.integer :interval, null: false, default: 0
      t.integer :ease, null: false, default: 2500
      t.integer :lapses, null: false, default: 0
      t.integer :reps, null: false, default: 0
      t.enum :state, enum_type: :card_state, null: false, default: "new"
      t.integer :position, null: false, default: 0
      t.integer :flag, null: false, default: 0, limit: 2
      t.boolean :suspended, null: false, default: false
      t.boolean :buried, null: false, default: false

      # FSRS-specific fields
      t.float :stability
      t.float :difficulty
      t.timestamp :last_review_at

      t.timestamps
    end

    # Constraints
    unless connection.select_value("SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_flag_range' AND table_name = 'cards'")
      execute <<-SQL
        ALTER TABLE cards
        ADD CONSTRAINT check_flag_range
        CHECK (flag >= 0 AND flag <= 7)
      SQL
    end

    unless connection.select_value("SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_ease_range' AND table_name = 'cards'")
      execute <<-SQL
        ALTER TABLE cards
        ADD CONSTRAINT check_ease_range
        CHECK (ease >= 1300)
      SQL
    end

    unless connection.select_value("SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_interval_non_negative' AND table_name = 'cards'")
      execute <<-SQL
        ALTER TABLE cards
        ADD CONSTRAINT check_interval_non_negative
        CHECK (interval >= 0)
      SQL
    end

    unless connection.select_value("SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_due_valid' AND table_name = 'cards'")
      execute <<-SQL
        ALTER TABLE cards
        ADD CONSTRAINT check_due_valid
        CHECK (due >= 0)
      SQL
    end

    unless connection.select_value("SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_home_deck' AND table_name = 'cards'")
      execute <<-SQL
        ALTER TABLE cards
        ADD CONSTRAINT check_home_deck
        CHECK (home_deck_id IS NULL OR home_deck_id != deck_id)
      SQL
    end

    unless connection.select_value("SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_review_interval' AND table_name = 'cards'")
      execute <<-SQL
        ALTER TABLE cards
        ADD CONSTRAINT check_review_interval
        CHECK (state != 'review' OR interval >= 0)
      SQL
    end

    unless connection.select_value("SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_review_due' AND table_name = 'cards'")
      execute <<-SQL
        ALTER TABLE cards
        ADD CONSTRAINT check_review_due
        CHECK (state != 'review' OR due > 1000000000000)
      SQL
    end

    unless connection.select_value("SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_new_position' AND table_name = 'cards'")
      execute <<-SQL
        ALTER TABLE cards
        ADD CONSTRAINT check_new_position
        CHECK (state != 'new' OR position >= 0)
      SQL
    end

    # Indexes
    unless index_exists?(:cards, :note_id)
      add_index :cards, :note_id, name: "idx_cards_note_id"
    end

    unless index_exists?(:cards, :deck_id)
      add_index :cards, :deck_id, name: "idx_cards_deck_id"
    end

    unless index_exists?(:cards, :home_deck_id, where: "home_deck_id IS NOT NULL")
      add_index :cards, :home_deck_id, where: "home_deck_id IS NOT NULL", name: "idx_cards_home_deck_id"
    end

    unless index_exists?(:cards, :due, where: "suspended = FALSE AND buried = FALSE")
      add_index :cards, :due, where: "suspended = FALSE AND buried = FALSE", name: "idx_cards_due"
    end

    unless index_exists?(:cards, :state, where: "suspended = FALSE AND buried = FALSE")
      add_index :cards, :state, where: "suspended = FALSE AND buried = FALSE", name: "idx_cards_state"
    end

    unless index_exists?(:cards, :flag, where: "flag > 0")
      add_index :cards, :flag, where: "flag > 0", name: "idx_cards_flag"
    end

    unless index_exists?(:cards, :suspended, where: "suspended = TRUE")
      add_index :cards, :suspended, where: "suspended = TRUE", name: "idx_cards_suspended"
    end

    unless index_exists?(:cards, :buried, where: "buried = TRUE")
      add_index :cards, :buried, where: "buried = TRUE", name: "idx_cards_buried"
    end

    unless index_exists?(:cards, :position, where: "state = 'new'")
      add_index :cards, :position, where: "state = 'new'", name: "idx_cards_position"
    end

    unless index_exists?(:cards, [:deck_id, :state, :due], where: "suspended = FALSE AND buried = FALSE")
      add_index :cards, [:deck_id, :state, :due], where: "suspended = FALSE AND buried = FALSE", name: "idx_cards_deck_state_due"
    end

    unless index_exists?(:cards, :stability, where: "stability IS NOT NULL")
      add_index :cards, :stability, where: "stability IS NOT NULL", name: "idx_cards_fsrs_stability"
    end

    unless index_exists?(:cards, :created_at)
      add_index :cards, :created_at, name: "idx_cards_created_at"
    end

    # Study query index (composite for efficient study queries)
    unless connection.select_value("SELECT 1 FROM pg_indexes WHERE indexname = 'idx_cards_study_query' AND tablename = 'cards'")
      execute <<-SQL
        CREATE INDEX idx_cards_study_query ON cards(deck_id, state, due, suspended, buried) WHERE suspended = FALSE AND buried = FALSE
      SQL
    end

    unless index_exists?(:cards, [:note_id, :state])
      add_index :cards, [:note_id, :state], name: "idx_cards_note_state"
    end

    unless index_exists?(:cards, [:note_id, :updated_at])
      add_index :cards, [:note_id, :updated_at], name: "idx_cards_sync"
    end
  end
end
