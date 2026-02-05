# frozen_string_literal: true

class CreateUserPreferences < ActiveRecord::Migration[7.2]
  def change
    create_table :user_preferences do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }

      # Localization
      t.string :language, null: false, default: "pt-BR"
      t.column :theme, :theme_type, null: false, default: "auto"

      # Sync settings
      t.boolean :auto_sync, null: false, default: true

      # Study timing
      t.time :next_day_starts_at, null: false, default: "04:00:00"
      t.integer :learn_ahead_limit, null: false, default: 20
      t.integer :timebox_time_limit, null: false, default: 0

      # UI settings
      t.string :video_driver, null: false, default: "auto"
      t.decimal :ui_size, null: false, default: 1.0, precision: 3, scale: 2
      t.boolean :minimalist_mode, null: false, default: false
      t.boolean :reduce_motion, null: false, default: false

      # Editing preferences
      t.boolean :paste_strips_formatting, null: false, default: false
      t.boolean :paste_images_as_png, null: false, default: false
      t.string :default_deck_behavior, null: false, default: "current_deck"

      # Audio/Video
      t.boolean :show_play_buttons, null: false, default: true
      t.boolean :interrupt_audio_on_answer, null: false, default: true

      # Study display
      t.boolean :show_remaining_count, null: false, default: true
      t.boolean :show_next_review_time, null: false, default: false
      t.boolean :spacebar_answers_card, null: false, default: true

      # Search
      t.boolean :ignore_accents_in_search, null: false, default: false
      t.string :default_search_text

      # Sync advanced
      t.boolean :sync_audio_and_images, null: false, default: true
      t.boolean :periodically_sync_media, null: false, default: false
      t.boolean :force_one_way_sync, null: false, default: false
      t.string :self_hosted_sync_server_url, limit: 512

      t.timestamps
    end

    # Add constraints
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE user_preferences
          ADD CONSTRAINT check_learn_ahead_limit CHECK (learn_ahead_limit >= 0);
        SQL

        execute <<-SQL
          ALTER TABLE user_preferences
          ADD CONSTRAINT check_timebox_limit CHECK (timebox_time_limit >= 0);
        SQL

        execute <<-SQL
          ALTER TABLE user_preferences
          ADD CONSTRAINT check_ui_size CHECK (ui_size > 0 AND ui_size <= 3.0);
        SQL
      end

      dir.down do
        execute "ALTER TABLE user_preferences DROP CONSTRAINT IF EXISTS check_learn_ahead_limit;"
        execute "ALTER TABLE user_preferences DROP CONSTRAINT IF EXISTS check_timebox_limit;"
        execute "ALTER TABLE user_preferences DROP CONSTRAINT IF EXISTS check_ui_size;"
      end
    end
  end
end
