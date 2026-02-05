# frozen_string_literal: true

FactoryBot.define do
  factory :user_preference do
    user
    language { "pt-BR" }
    theme { "auto" }
    auto_sync { true }
    next_day_starts_at { "04:00:00" }
    learn_ahead_limit { 20 }
    timebox_time_limit { 0 }
    video_driver { "auto" }
    ui_size { 1.0 }
    minimalist_mode { false }
    reduce_motion { false }
    paste_strips_formatting { false }
    paste_images_as_png { false }
    default_deck_behavior { "current_deck" }
    show_play_buttons { true }
    interrupt_audio_on_answer { true }
    show_remaining_count { true }
    show_next_review_time { false }
    spacebar_answers_card { true }
    ignore_accents_in_search { false }
    default_search_text { nil }
    sync_audio_and_images { true }
    periodically_sync_media { false }
    force_one_way_sync { false }
    self_hosted_sync_server_url { nil }

    trait :dark_theme do
      theme { "dark" }
    end

    trait :english do
      language { "en" }
    end
  end
end
