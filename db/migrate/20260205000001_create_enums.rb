# frozen_string_literal: true

class CreateEnums < ActiveRecord::Migration[7.2]
  def up
    # Enable unaccent extension for accent-insensitive search
    enable_extension "unaccent"

    # Card states: new -> learn -> review -> relearn
    execute <<-SQL
      CREATE TYPE card_state AS ENUM ('new', 'learn', 'review', 'relearn');
    SQL

    # Review types
    execute <<-SQL
      CREATE TYPE review_type AS ENUM ('learn', 'review', 'relearn', 'cram');
    SQL

    # Theme types for user preferences
    execute <<-SQL
      CREATE TYPE theme_type AS ENUM ('light', 'dark', 'auto');
    SQL

    # Spaced repetition algorithm types
    execute <<-SQL
      CREATE TYPE scheduler_type AS ENUM ('sm2', 'fsrs');
    SQL
  end

  def down
    execute "DROP TYPE IF EXISTS scheduler_type;"
    execute "DROP TYPE IF EXISTS theme_type;"
    execute "DROP TYPE IF EXISTS review_type;"
    execute "DROP TYPE IF EXISTS card_state;"
    disable_extension "unaccent"
  end
end
