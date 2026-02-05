# frozen_string_literal: true

class CreateReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :reviews, if_not_exists: true do |t|
      t.references :card, null: false, foreign_key: true, type: :bigint, index: false
      t.integer :rating, null: false, limit: 2
      t.integer :interval, null: false
      t.integer :ease, null: false
      t.integer :time_ms, null: false
      t.enum :review_type, enum_type: :review_type, null: false

      t.timestamps
    end

    # Constraints
    unless connection.select_value("SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_rating_range' AND table_name = 'reviews'")
      execute <<-SQL
        ALTER TABLE reviews
        ADD CONSTRAINT check_rating_range
        CHECK (rating >= 1 AND rating <= 4)
      SQL
    end

    unless connection.select_value("SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_time_ms_positive' AND table_name = 'reviews'")
      execute <<-SQL
        ALTER TABLE reviews
        ADD CONSTRAINT check_time_ms_positive
        CHECK (time_ms > 0)
      SQL
    end

    unless connection.select_value("SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_interval_valid' AND table_name = 'reviews'")
      execute <<-SQL
        ALTER TABLE reviews
        ADD CONSTRAINT check_interval_valid
        CHECK (interval != 0)
      SQL
    end

    # Indexes
    unless index_exists?(:reviews, :card_id)
      add_index :reviews, :card_id, name: "idx_reviews_card_id"
    end

    unless index_exists?(:reviews, :created_at)
      add_index :reviews, :created_at, name: "idx_reviews_created_at"
    end

    unless index_exists?(:reviews, [:card_id, :created_at])
      add_index :reviews, [:card_id, :created_at], name: "idx_reviews_card_created"
    end
  end
end
