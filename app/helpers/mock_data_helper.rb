# frozen_string_literal: true

module MockDataHelper
  # Returns a hierarchical deck tree with card counts
  def mock_deck_tree
    [
      {
        id: 1, name: "Default", full_name: "Default", depth: 0, collapsed: false,
        new_count: 5, learn_count: 3, due_count: 12, total: 150,
        children: []
      },
      {
        id: 2, name: "Japanese", full_name: "Japanese", depth: 0, collapsed: false,
        new_count: 25, learn_count: 8, due_count: 47, total: 820,
        children: [
          {
            id: 3, name: "Vocabulary", full_name: "Japanese::Vocabulary", depth: 1, collapsed: false,
            new_count: 15, learn_count: 5, due_count: 30, total: 520,
            children: [
              { id: 7, name: "JLPT N5", full_name: "Japanese::Vocabulary::JLPT N5", depth: 2, collapsed: false,
                new_count: 5, learn_count: 2, due_count: 10, total: 200, children: [] },
              { id: 8, name: "JLPT N4", full_name: "Japanese::Vocabulary::JLPT N4", depth: 2, collapsed: false,
                new_count: 10, learn_count: 3, due_count: 20, total: 320, children: [] }
            ]
          },
          {
            id: 4, name: "Kanji", full_name: "Japanese::Kanji", depth: 1, collapsed: false,
            new_count: 8, learn_count: 2, due_count: 15, total: 250,
            children: []
          },
          {
            id: 5, name: "Grammar", full_name: "Japanese::Grammar", depth: 1, collapsed: false,
            new_count: 2, learn_count: 1, due_count: 2, total: 50,
            children: []
          }
        ]
      },
      {
        id: 6, name: "Spanish", full_name: "Spanish", depth: 0, collapsed: false,
        new_count: 10, learn_count: 4, due_count: 22, total: 340,
        children: [
          {
            id: 9, name: "Vocabulary", full_name: "Spanish::Vocabulary", depth: 1, collapsed: false,
            new_count: 7, learn_count: 3, due_count: 18, total: 280,
            children: []
          },
          {
            id: 10, name: "Conjugation", full_name: "Spanish::Conjugation", depth: 1, collapsed: false,
            new_count: 3, learn_count: 1, due_count: 4, total: 60,
            children: []
          }
        ]
      }
    ]
  end

  # Summary totals for the deck tree
  def mock_deck_totals
    { new_count: 40, learn_count: 15, due_count: 81 }
  end

  # Returns mock study card data
  def mock_study_card
    {
      id: 42,
      deck_name: "Japanese::Vocabulary::JLPT N5",
      new_remaining: 5,
      learn_remaining: 3,
      review_remaining: 12,
      front_html: "<div style='font-size: 2.5rem; font-weight: bold;'>食べる</div>",
      back_html: "<div style='font-size: 2.5rem; font-weight: bold;'>食べる</div><hr class='my-4'><div style='font-size: 1.5rem;'>to eat (taberu)</div><div class='text-gray-500 mt-2'>Ichidan verb, transitive</div>",
      intervals: { again: "< 1m", hard: "6m", good: "10m", easy: "4d" },
      elapsed_time: "0:15",
      progress_percent: 35,
      card_number: 7,
      total_cards: 20,
      flag: 0
    }
  end

  # Returns mock congratulations data
  def mock_congrats
    {
      cards_studied: 47,
      time_spent: "23 minutes",
      correct_percent: 87.2,
      again_count: 6,
      hard_count: 8,
      good_count: 28,
      easy_count: 5,
      next_due: "4 hours",
      next_due_count: 12
    }
  end

  # Returns mock browser data for the card browser
  def mock_browser_data
    {
      cards: [
        { id: 1, sort_field: "食べる", card_type: "Basic", due: "2026-02-07", deck: "Japanese::Vocabulary", tags: ["verb", "jlpt-n5"], note_id: 1, front: "<b>食べる</b>", back: "to eat", state: "review", interval: "15d", ease: "250%", flag: 0 },
        { id: 2, sort_field: "飲む", card_type: "Basic", due: "2026-02-08", deck: "Japanese::Vocabulary", tags: ["verb", "jlpt-n5"], note_id: 2, front: "<b>飲む</b>", back: "to drink", state: "review", interval: "22d", ease: "260%", flag: 0 },
        { id: 3, sort_field: "行く", card_type: "Basic", due: "Today", deck: "Japanese::Vocabulary", tags: ["verb", "jlpt-n5", "irregular"], note_id: 3, front: "<b>行く</b>", back: "to go", state: "learning", interval: "10m", ease: "250%", flag: 1 },
        { id: 4, sort_field: "大きい", card_type: "Basic", due: "2026-02-10", deck: "Japanese::Vocabulary", tags: ["adjective", "jlpt-n5"], note_id: 4, front: "<b>大きい</b>", back: "big, large", state: "review", interval: "45d", ease: "290%", flag: 0 },
        { id: 5, sort_field: "小さい", card_type: "Basic", due: "2026-02-06", deck: "Japanese::Vocabulary", tags: ["adjective", "jlpt-n5"], note_id: 5, front: "<b>小さい</b>", back: "small, little", state: "review", interval: "30d", ease: "270%", flag: 0 },
        { id: 6, sort_field: "hola", card_type: "Basic", due: "New", deck: "Spanish::Vocabulary", tags: ["greeting"], note_id: 6, front: "<b>hola</b>", back: "hello", state: "new", interval: "", ease: "", flag: 0 },
        { id: 7, sort_field: "gracias", card_type: "Basic", due: "New", deck: "Spanish::Vocabulary", tags: ["greeting", "essential"], note_id: 7, front: "<b>gracias</b>", back: "thank you", state: "new", interval: "", ease: "", flag: 0 },
        { id: 8, sort_field: "comer", card_type: "Basic (and reversed)", due: "2026-02-09", deck: "Spanish::Vocabulary", tags: ["verb", "regular"], note_id: 8, front: "<b>comer</b>", back: "to eat", state: "review", interval: "12d", ease: "240%", flag: 2 },
        { id: 9, sort_field: "一", card_type: "Kanji", due: "2026-02-06", deck: "Japanese::Kanji", tags: ["jlpt-n5", "number"], note_id: 9, front: "<span style='font-size:3rem'>一</span>", back: "one (いち)", state: "review", interval: "60d", ease: "300%", flag: 0 },
        { id: 10, sort_field: "二", card_type: "Kanji", due: "2026-02-11", deck: "Japanese::Kanji", tags: ["jlpt-n5", "number"], note_id: 10, front: "<span style='font-size:3rem'>二</span>", back: "two (に)", state: "review", interval: "55d", ease: "280%", flag: 0 },
        { id: 11, sort_field: "三", card_type: "Kanji", due: "2026-02-07", deck: "Japanese::Kanji", tags: ["jlpt-n5", "number"], note_id: 11, front: "<span style='font-size:3rem'>三</span>", back: "three (さん)", state: "review", interval: "40d", ease: "260%", flag: 0 },
        { id: 12, sort_field: "te form", card_type: "Basic", due: "2026-02-12", deck: "Japanese::Grammar", tags: ["grammar", "jlpt-n5"], note_id: 12, front: "How to form the <b>te-form</b>?", back: "Change verb ending...", state: "review", interval: "20d", ease: "250%", flag: 0 }
      ],
      sidebar: {
        decks: mock_deck_tree,
        note_types: [
          { id: 1, name: "Basic", count: 8 },
          { id: 2, name: "Basic (and reversed card)", count: 1 },
          { id: 3, name: "Kanji", count: 3 },
          { id: 4, name: "Cloze", count: 0 }
        ],
        tags: [
          { name: "adjective", count: 2 },
          { name: "essential", count: 1 },
          { name: "grammar", count: 1 },
          { name: "greeting", count: 2 },
          { name: "irregular", count: 1 },
          { name: "jlpt-n5", count: 10 },
          { name: "number", count: 3 },
          { name: "regular", count: 1 },
          { name: "verb", count: 4 }
        ],
        flags: [
          { number: 1, name: "Red", color: "red", count: 1 },
          { number: 2, name: "Orange", color: "orange", count: 1 },
          { number: 3, name: "Green", color: "green", count: 0 },
          { number: 4, name: "Blue", color: "blue", count: 0 },
          { number: 5, name: "Pink", color: "pink", count: 0 },
          { number: 6, name: "Turquoise", color: "teal", count: 0 },
          { number: 7, name: "Purple", color: "purple", count: 0 }
        ],
        saved_searches: [
          { id: 1, name: "Due today", query: "is:due" },
          { id: 2, name: "New cards", query: "is:new" },
          { id: 3, name: "Flagged", query: "flag:1" },
          { id: 4, name: "Leeches", query: "tag:leech" }
        ]
      },
      total_count: 12
    }
  end

  # Returns mock statistics data
  def mock_statistics
    today = Date.today
    {
      today_stats: {
        studied: 47,
        time_spent: "23m",
        again_count: 6,
        correct_percent: 87.2,
        mature_correct: 92.1,
        young_correct: 78.3
      },
      reviews_per_day: (30.days.ago.to_date..today).map { |d| [d.strftime("%b %d"), rand(10..80)] }.to_h,
      future_due: (today..(today + 30)).map { |d|
        [d.strftime("%b %d"), { "Review" => rand(5..40), "Learning" => rand(0..10), "New" => rand(0..5) }]
      }.to_h,
      card_counts: { "New" => 40, "Learning" => 15, "Young" => 320, "Mature" => 935 },
      interval_distribution: {
        "0-1d" => 15, "1-3d" => 25, "3-7d" => 45, "7-14d" => 60,
        "14-30d" => 120, "1-3mo" => 280, "3-6mo" => 190, "6-12mo" => 150, "1yr+" => 115
      },
      ease_distribution: {
        "130%" => 5, "140%" => 8, "150%" => 12, "160%" => 18, "170%" => 22,
        "180%" => 30, "190%" => 35, "200%" => 42, "210%" => 55, "220%" => 68,
        "230%" => 75, "240%" => 82, "250%" => 180, "260%" => 90, "270%" => 65,
        "280%" => 48, "290%" => 30, "300%" => 25, "310%" => 15, "320%" => 8
      },
      hourly_breakdown: (0..23).map { |h| ["#{h}:00", rand(0..30)] }.to_h,
      answer_buttons: { "Again" => 45, "Hard" => 85, "Good" => 310, "Easy" => 60 },
      added_per_day: (30.days.ago.to_date..today).map { |d| [d.strftime("%b %d"), rand(0..15)] }.to_h,
      calendar_heatmap: (365.days.ago.to_date..today).map { |d| [d.iso8601, rand(0..120)] }.to_h
    }
  end

  # Returns mock deck options preset data
  def mock_deck_options
    {
      presets: [
        { id: 1, name: "Default", is_default: true },
        { id: 2, name: "Hard Mode", is_default: false },
        { id: 3, name: "Language Learning", is_default: false }
      ],
      current: {
        id: 1, name: "Default",
        daily_limits: { new_cards: 20, max_reviews: 200, new_today: "5/20", reviews_today: "47/200" },
        new_cards: {
          learning_steps: "1m 10m",
          graduating_interval: 1,
          easy_interval: 4,
          insertion_order: "Sequential"
        },
        lapses: {
          relearning_steps: "10m",
          minimum_interval: 1,
          leech_threshold: 8,
          leech_action: "Tag Only"
        },
        display: {
          show_timer: true,
          autoplay_audio: true,
          auto_advance: false,
          auto_advance_seconds: 10
        },
        burying: {
          bury_new_siblings: true,
          bury_review_siblings: true,
          bury_interday_learning: true
        },
        advanced: {
          maximum_interval: 36500,
          starting_ease: 2.5,
          easy_bonus: 1.3,
          interval_modifier: 1.0,
          hard_interval: 1.2,
          new_interval: 0.0
        }
      }
    }
  end

  # Returns mock card info for the card info view
  def mock_card_info
    {
      card_id: 42,
      note_id: 15,
      deck: "Japanese::Vocabulary::JLPT N5",
      card_type: "Basic",
      note_type: "Basic",
      front_html: "<b>食べる</b>",
      back_html: "to eat (taberu)",
      tags: ["verb", "jlpt-n5", "ichidan"],
      stats: {
        position: 42,
        due: "Feb 7, 2026",
        interval: "15 days",
        ease: "250%",
        reviews: 12,
        lapses: 1,
        average_time: "8.2s",
        total_time: "1m 38s",
        card_type: "Review",
        created: "Jan 1, 2026",
        first_review: "Jan 2, 2026",
        latest_review: "Jan 23, 2026",
        stability: "15.0 days",
        difficulty: "5.2",
        retrievability: "90%"
      },
      reviews: [
        { date: "Jan 23, 2026", rating: "Good", interval: "15d", ease: "250%", time: "6.2s", type: "Review" },
        { date: "Jan 8, 2026", rating: "Good", interval: "8d", ease: "250%", time: "8.1s", type: "Review" },
        { date: "Dec 31, 2025", rating: "Hard", interval: "4d", ease: "230%", time: "12.4s", type: "Review" },
        { date: "Dec 27, 2025", rating: "Good", interval: "2d", ease: "250%", time: "5.0s", type: "Review" },
        { date: "Dec 25, 2025", rating: "Again", interval: "10m", ease: "250%", time: "15.1s", type: "Relearn" },
        { date: "Dec 25, 2025", rating: "Good", interval: "1d", ease: "250%", time: "7.3s", type: "Review" },
        { date: "Dec 24, 2025", rating: "Good", interval: "10m", ease: "250%", time: "9.8s", type: "Learn" },
        { date: "Dec 24, 2025", rating: "Good", interval: "1m", ease: "250%", time: "11.2s", type: "Learn" },
        { date: "Dec 24, 2025", rating: "Again", interval: "", ease: "250%", time: "20.0s", type: "Learn" }
      ]
    }
  end

  # Returns mock note types list
  def mock_note_types
    [
      { id: 1, name: "Basic", fields: ["Front", "Back"], card_types: ["Card 1"], note_count: 450 },
      { id: 2, name: "Basic (and reversed card)", fields: ["Front", "Back"], card_types: ["Card 1", "Card 2"], note_count: 85 },
      { id: 3, name: "Basic (optional reversed card)", fields: ["Front", "Back", "Add Reverse"], card_types: ["Card 1", "Card 2"], note_count: 30 },
      { id: 4, name: "Cloze", fields: ["Text", "Extra"], card_types: ["Cloze"], note_count: 120 },
      { id: 5, name: "Basic (type in the answer)", fields: ["Front", "Back"], card_types: ["Card 1"], note_count: 25 },
      { id: 6, name: "Kanji", fields: ["Kanji", "Reading", "Meaning", "Examples"], card_types: ["Recognition", "Recall"], note_count: 250 }
    ]
  end

  # Returns mock note type detail for the editor
  def mock_note_type_detail
    {
      id: 1, name: "Basic",
      fields: [
        { name: "Front", ordinal: 0, font: "Arial", size: 20, rtl: false, sticky: false, description: "The question side" },
        { name: "Back", ordinal: 1, font: "Arial", size: 20, rtl: false, sticky: false, description: "The answer side" }
      ],
      card_types: [
        {
          name: "Card 1", ordinal: 0,
          front_template: "{{Front}}",
          back_template: "{{FrontSide}}\n\n<hr id=answer>\n\n{{Back}}",
          styling: ".card {\n  font-family: arial;\n  font-size: 20px;\n  text-align: center;\n  color: black;\n  background-color: white;\n}"
        }
      ]
    }
  end

  # Returns mock saved searches
  def mock_saved_searches
    [
      { id: 1, name: "Due today", query: "is:due", built_in: true },
      { id: 2, name: "Added today", query: "added:1", built_in: true },
      { id: 3, name: "Studied today", query: "rated:1", built_in: true },
      { id: 4, name: "New cards", query: "is:new", built_in: true },
      { id: 5, name: "Learning", query: "is:learn", built_in: true },
      { id: 6, name: "Leeches", query: "tag:leech", built_in: false },
      { id: 7, name: "Suspended", query: "is:suspended", built_in: false },
      { id: 8, name: "Flagged", query: "flag:1 OR flag:2 OR flag:3", built_in: false }
    ]
  end

  # Returns mock flag names
  def mock_flag_names
    [
      { number: 1, name: "Important", color: "#EF4444" },
      { number: 2, name: "Review Later", color: "#F97316" },
      { number: 3, name: "Easy", color: "#22C55E" },
      { number: 4, name: "To Research", color: "#3B82F6" },
      { number: 5, name: "", color: "#EC4899" },
      { number: 6, name: "", color: "#14B8A6" },
      { number: 7, name: "", color: "#8B5CF6" }
    ]
  end

  # Mock all tags for autocomplete
  def mock_all_tags
    %w[adjective essential grammar greeting ichidan irregular jlpt-n4 jlpt-n5 number regular verb leech marked]
  end

  # ============================================
  # Batch 1 — Media Browser + Check Database
  # ============================================

  def mock_media_data
    [
      { id: 1, filename: "taberu_pronunciation.mp3", type: "audio", mime_type: "audio/mpeg", size: 245_760, usage_count: 3, created_at: "2026-01-15", notes: ["食べる", "食べます"] },
      { id: 2, filename: "kanji_one.png", type: "image", mime_type: "image/png", size: 82_432, usage_count: 1, created_at: "2026-01-20", notes: ["一"] },
      { id: 3, filename: "japan_flag.jpg", type: "image", mime_type: "image/jpeg", size: 156_800, usage_count: 2, created_at: "2026-01-22", notes: ["Japanese Culture", "Geography"] },
      { id: 4, filename: "nomu_audio.ogg", type: "audio", mime_type: "audio/ogg", size: 198_400, usage_count: 1, created_at: "2026-01-25", notes: ["飲む"] },
      { id: 5, filename: "stroke_order.mp4", type: "video", mime_type: "video/mp4", size: 2_457_600, usage_count: 0, created_at: "2026-01-28", notes: [] },
      { id: 6, filename: "vocabulary_chart.png", type: "image", mime_type: "image/png", size: 340_200, usage_count: 4, created_at: "2026-02-01", notes: ["JLPT N5 Overview", "Study Guide", "Vocab List", "Summary"] },
      { id: 7, filename: "greeting_hola.mp3", type: "audio", mime_type: "audio/mpeg", size: 112_640, usage_count: 1, created_at: "2026-02-03", notes: ["hola"] },
      { id: 8, filename: "old_screenshot.png", type: "image", mime_type: "image/png", size: 520_400, usage_count: 0, created_at: "2025-12-10", notes: [] },
      { id: 9, filename: "comer_conjugation.webm", type: "video", mime_type: "video/webm", size: 1_843_200, usage_count: 1, created_at: "2026-02-04", notes: ["comer"] },
      { id: 10, filename: "hiragana_chart.gif", type: "image", mime_type: "image/gif", size: 425_984, usage_count: 5, created_at: "2025-11-30", notes: ["Hiragana あ", "Hiragana か", "Hiragana さ", "Hiragana た", "Hiragana な"] }
    ]
  end

  def mock_check_database_logs
    [
      { id: 1, checked_at: "2026-02-05 14:32", status: "ok", issues_found: 0, execution_time: "1.2s" },
      { id: 2, checked_at: "2026-01-28 09:15", status: "issues_found", issues_found: 3, execution_time: "2.8s" },
      { id: 3, checked_at: "2026-01-20 16:45", status: "ok", issues_found: 0, execution_time: "1.5s" },
      { id: 4, checked_at: "2026-01-10 11:00", status: "issues_found", issues_found: 1, execution_time: "1.9s" },
      { id: 5, checked_at: "2025-12-30 08:22", status: "ok", issues_found: 0, execution_time: "1.1s" }
    ]
  end

  def mock_check_database_log_detail
    {
      id: 2, checked_at: "2026-01-28 09:15", status: "issues_found",
      issues_found: 3, execution_time: "2.8s",
      summary: "Found 3 issues: 2 orphaned cards, 1 missing note type reference.",
      issues: [
        { type: "orphaned_card", description: "Card #1523 references non-existent note #890", severity: "warning", fixed: true },
        { type: "orphaned_card", description: "Card #1524 references non-existent note #890", severity: "warning", fixed: true },
        { type: "missing_reference", description: "Note #445 references note type ID 99 which does not exist", severity: "error", fixed: false }
      ]
    }
  end

  # ============================================
  # Batch 2 — Backups + Profiles
  # ============================================

  def mock_backups
    [
      { id: 1, filename: "backup-2026-02-05-143200.colpkg", type: "automatic", size: 45_678_592, created_at: "2026-02-05 14:32", notes_count: 960, cards_count: 1310 },
      { id: 2, filename: "backup-2026-02-04-090000.colpkg", type: "automatic", size: 45_234_176, created_at: "2026-02-04 09:00", notes_count: 955, cards_count: 1300 },
      { id: 3, filename: "manual-backup-pre-import.colpkg", type: "manual", size: 44_890_112, created_at: "2026-02-03 16:20", notes_count: 950, cards_count: 1295 },
      { id: 4, filename: "backup-2026-02-03-090000.colpkg", type: "automatic", size: 44_556_288, created_at: "2026-02-03 09:00", notes_count: 948, cards_count: 1290 },
      { id: 5, filename: "pre-update-backup.colpkg", type: "pre_operation", size: 43_200_512, created_at: "2026-01-30 11:45", notes_count: 940, cards_count: 1280 },
      { id: 6, filename: "backup-2026-01-29-090000.colpkg", type: "automatic", size: 42_800_128, created_at: "2026-01-29 09:00", notes_count: 935, cards_count: 1275 }
    ]
  end

  def mock_backup_stats
    { total_backups: 6, total_size: "256 MB", last_backup: "2026-02-05 14:32", auto_backup: true, retention_days: 30 }
  end

  def mock_profiles
    [
      { id: 1, name: "Default", active: true, sync_enabled: true, ankiweb_username: "user@example.com", cards_count: 1310, notes_count: 960, created_at: "2025-10-15" },
      { id: 2, name: "Work", active: false, sync_enabled: false, ankiweb_username: nil, cards_count: 245, notes_count: 180, created_at: "2025-12-01" },
      { id: 3, name: "Language Study", active: false, sync_enabled: true, ankiweb_username: "lang@example.com", cards_count: 3200, notes_count: 2100, created_at: "2025-11-10" }
    ]
  end

  def mock_profile_detail
    {
      id: 1, name: "Default", active: true,
      sync_enabled: true, ankiweb_username: "user@example.com",
      cards_count: 1310, notes_count: 960, decks_count: 10, note_types_count: 6,
      collection_size: "45.7 MB", media_size: "12.3 MB",
      created_at: "2025-10-15", last_synced: "2026-02-05 14:30"
    }
  end

  # ============================================
  # Batch 3 — Filtered Decks + Add-ons
  # ============================================

  def mock_filtered_decks
    [
      { id: 1, name: "Cram: Due Today", search_filter: "is:due prop:due<=0", card_count: 47, limit: 100, order: "Random", reschedule: true, last_rebuild: "2026-02-06 08:00", created_at: "2026-01-15" },
      { id: 2, name: "Difficult Cards", search_filter: "prop:ease<2.0 is:review", card_count: 23, limit: 50, order: "Increasing intervals", reschedule: true, last_rebuild: "2026-02-05 19:30", created_at: "2026-01-20" },
      { id: 3, name: "Japanese Leeches", search_filter: "deck:Japanese tag:leech", card_count: 8, limit: 20, order: "Oldest seen first", reschedule: false, last_rebuild: "2026-02-04 10:00", created_at: "2026-02-01" }
    ]
  end

  def mock_filtered_deck_detail
    {
      id: 1, name: "Cram: Due Today",
      search_filter: "is:due prop:due<=0",
      search_filter_2: nil,
      card_count: 47, limit: 100,
      order: "Random", reschedule: true,
      last_rebuild: "2026-02-06 08:00",
      created_at: "2026-01-15",
      cards_new: 5, cards_learn: 12, cards_review: 30
    }
  end

  def mock_add_ons
    [
      { id: 1, name: "Review Heatmap", code: "1771074083", version: "1.0.2", enabled: true, has_config: true, author: "Glutanimate", description: "Adds a heatmap graph to the deck overview page." },
      { id: 2, name: "Night Mode", code: "1496166067", version: "2.3.1", enabled: true, has_config: true, author: "krassowski", description: "Automatic dark mode for all Anki screens." },
      { id: 3, name: "Edit Field During Review", code: "1020366288", version: "3.0.0", enabled: false, has_config: false, author: "AnKingMed", description: "Edit cards without opening the editor." },
      { id: 4, name: "Image Occlusion Enhanced", code: "1374772155", version: "1.4.0", enabled: true, has_config: true, author: "Glutanimate", description: "Create image occlusion cards with ease." },
      { id: 5, name: "Advanced Browser", code: "874215009", version: "2.1.0", enabled: true, has_config: false, author: "hssm", description: "Adds more columns and features to the card browser." }
    ]
  end

  def mock_add_on_detail
    {
      id: 1, name: "Review Heatmap", code: "1771074083", version: "1.0.2",
      enabled: true, author: "Glutanimate",
      description: "Adds a heatmap graph to the deck overview page.",
      config: "{\n  \"colors\": \"lime\",\n  \"activity_type\": 0,\n  \"limdate\": 0,\n  \"limhist\": 0,\n  \"limfcst\": 0,\n  \"whole\": true\n}"
    }
  end

  # ============================================
  # Batch 4 — Shared Decks
  # ============================================

  def mock_shared_decks
    [
      { id: 1, title: "Ultimate JLPT N5 Vocabulary", author: "JapaneseStudy", stars: 4.8, ratings_count: 342, downloads: 15_420, category: "Japanese", description: "Comprehensive JLPT N5 vocabulary deck with audio and example sentences.", size: "12.4 MB", cards_count: 800, updated_at: "2026-01-20", featured: true },
      { id: 2, title: "Spanish Core 2000", author: "LanguageLearner", stars: 4.5, ratings_count: 189, downloads: 8_930, category: "Spanish", description: "Top 2000 most common Spanish words with native audio.", size: "8.7 MB", cards_count: 2000, updated_at: "2026-01-15", featured: true },
      { id: 3, title: "Medical Terminology", author: "MedStudent2026", stars: 4.7, ratings_count: 256, downloads: 12_100, category: "Medicine", description: "Complete medical terminology with Latin roots and mnemonics.", size: "3.2 MB", cards_count: 1500, updated_at: "2026-02-01", featured: false },
      { id: 4, title: "European Capitals", author: "GeoNerd", stars: 4.2, ratings_count: 67, downloads: 3_450, category: "Geography", description: "All European capitals with flags and map locations.", size: "5.1 MB", cards_count: 50, updated_at: "2025-12-20", featured: false },
      { id: 5, title: "Kanji RTK Order", author: "KanjiMaster", stars: 4.6, ratings_count: 410, downloads: 22_300, category: "Japanese", description: "All 2200 Joyo kanji in Remembering the Kanji order.", size: "1.8 MB", cards_count: 2200, updated_at: "2026-01-30", featured: true },
      { id: 6, title: "French Verb Conjugations", author: "FrenchTeacher", stars: 4.3, ratings_count: 95, downloads: 4_200, category: "French", description: "Complete conjugation tables for the 100 most common French verbs.", size: "2.1 MB", cards_count: 600, updated_at: "2026-01-10", featured: false }
    ]
  end

  def mock_shared_deck_categories
    ["All", "Japanese", "Spanish", "French", "German", "Medicine", "Geography", "Science", "History", "Computer Science"]
  end

  def mock_featured_shared_decks
    mock_shared_decks.select { |d| d[:featured] }
  end

  def mock_shared_deck_detail
    {
      id: 1, title: "Ultimate JLPT N5 Vocabulary", author: "JapaneseStudy",
      stars: 4.8, ratings_count: 342, downloads: 15_420,
      category: "Japanese", tags: ["jlpt", "n5", "vocabulary", "audio"],
      description: "This comprehensive deck covers all vocabulary words needed for the JLPT N5 exam. Each card includes:\n\n- Japanese word in kanji and hiragana\n- English translation\n- Example sentence\n- Native audio pronunciation\n\nCards are organized by frequency of use. Regular updates based on latest exam trends.",
      size: "12.4 MB", cards_count: 800, note_count: 800,
      sample_cards: [
        { front: "食べる (たべる)", back: "to eat" },
        { front: "飲む (のむ)", back: "to drink" },
        { front: "行く (いく)", back: "to go" }
      ],
      updated_at: "2026-01-20", created_at: "2025-06-15"
    }
  end

  def mock_shared_deck_ratings
    [
      { id: 1, user: "StudyPro", stars: 5, comment: "Excellent deck! Audio quality is great and the example sentences really help.", created_at: "2026-02-01" },
      { id: 2, user: "NihongoLearner", stars: 4, comment: "Very comprehensive. Would be perfect with more example sentences for each word.", created_at: "2026-01-28" },
      { id: 3, user: "BeginnerJP", stars: 5, comment: "This got me through the N5 exam. Highly recommended for beginners.", created_at: "2026-01-20" },
      { id: 4, user: "PolyglotKing", stars: 4, comment: "Good content but some audio files are a bit quiet.", created_at: "2026-01-15" }
    ]
  end

  # ============================================
  # Batch 5 — Deletion Log + Undo History + Sync
  # ============================================

  def mock_deletion_logs
    [
      { id: 1, object_type: "note", summary: "Note: 食べる (Basic)", deleted_at: "2026-02-05 16:30", deletable_id: 15 },
      { id: 2, object_type: "card", summary: "Card #1523 from deck Japanese::Vocabulary", deleted_at: "2026-02-05 14:20", deletable_id: 1523 },
      { id: 3, object_type: "card", summary: "Card #1524 from deck Japanese::Vocabulary", deleted_at: "2026-02-05 14:20", deletable_id: 1524 },
      { id: 4, object_type: "deck", summary: "Deck: Test Deck (empty)", deleted_at: "2026-02-04 09:00", deletable_id: 20 },
      { id: 5, object_type: "note_type", summary: "Note Type: Old Template", deleted_at: "2026-02-03 11:15", deletable_id: 8 },
      { id: 6, object_type: "note", summary: "Note: comer (Basic and reversed)", deleted_at: "2026-02-02 18:45", deletable_id: 22 },
      { id: 7, object_type: "note", summary: "Note: dormir (Basic)", deleted_at: "2026-02-01 10:30", deletable_id: 25 }
    ]
  end

  def mock_deletion_log_detail
    {
      id: 1, object_type: "note", summary: "Note: 食べる (Basic)",
      deleted_at: "2026-02-05 16:30", deletable_id: 15,
      object_data: {
        note_type: "Basic",
        fields: { "Front" => "食べる", "Back" => "to eat (taberu)" },
        tags: ["verb", "jlpt-n5", "ichidan"],
        deck: "Japanese::Vocabulary::JLPT N5",
        cards_count: 1,
        created_at: "2025-12-24"
      }
    }
  end

  def mock_undo_history
    [
      { id: 1, operation: "delete", summary: "Deleted note: 食べる", timestamp: "2026-02-05 16:30", details: "1 note, 1 card removed" },
      { id: 2, operation: "edit", summary: "Edited note: 飲む", timestamp: "2026-02-05 15:45", details: "Changed Back field" },
      { id: 3, operation: "review", summary: "Reviewed card #42", timestamp: "2026-02-05 15:30", details: "Answered 'Good', interval: 15d" },
      { id: 4, operation: "add", summary: "Added note: nuevo", timestamp: "2026-02-05 14:00", details: "Added to Spanish::Vocabulary" },
      { id: 5, operation: "move", summary: "Moved 5 cards", timestamp: "2026-02-05 12:30", details: "From Default to Japanese::Grammar" },
      { id: 6, operation: "bulk_edit", summary: "Bulk tag: 12 notes", timestamp: "2026-02-04 18:00", details: "Added tag 'review-needed'" },
      { id: 7, operation: "suspend", summary: "Suspended 3 cards", timestamp: "2026-02-04 16:20", details: "Cards #100, #101, #102" },
      { id: 8, operation: "import", summary: "Imported deck: French Basics", timestamp: "2026-02-03 10:00", details: "150 notes, 300 cards added" }
    ]
  end

  def mock_undo_history_detail
    {
      id: 2, operation: "edit", summary: "Edited note: 飲む",
      timestamp: "2026-02-05 15:45",
      before: { "Front" => "飲む", "Back" => "to drink" },
      after: { "Front" => "飲む", "Back" => "to drink (nomu) - Godan verb" }
    }
  end

  def mock_sync_devices
    [
      { id: 1, client_name: "Rebisyon Web (Chrome)", last_sync: "2026-02-06 08:30", usn: 1542, device_type: "web" },
      { id: 2, client_name: "AnkiDroid (Pixel 8)", last_sync: "2026-02-05 22:15", usn: 1540, device_type: "android" },
      { id: 3, client_name: "Anki Desktop (macOS)", last_sync: "2026-02-04 18:00", usn: 1535, device_type: "desktop" }
    ]
  end

  def mock_sync_status
    {
      connected: true, last_sync: "2026-02-06 08:30",
      server_url: "https://sync.rebisyon.com",
      pending_changes: 3, server_usn: 1542,
      full_sync_required: false
    }
  end
end
