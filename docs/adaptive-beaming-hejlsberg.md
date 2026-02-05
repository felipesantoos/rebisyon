# Rebisyon: Rails 8 Monolith Implementation Plan

## Overview

Build a full Ruby on Rails 8 monolith (Hotwire/Turbo/Stimulus) implementing an Anki-like spaced repetition system based on 23 database tables, 127+ business rules, and 1100+ feature tickets defined in the project docs.

**Stack**: Ruby 3.3 + Rails 8 + PostgreSQL 16+ + Hotwire + Devise/JWT + Solid Queue/Cache/Cable + Tailwind CSS

---

## Architecture Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Schema format | `structure.sql` | PG enums, partial indexes, GIN indexes, triggers, CHECK constraints |
| Auth (web) | Devise sessions | Standard cookie auth for Hotwire views |
| Auth (API) | Devise + JWT | `/api/v1/` namespace with JWT for future mobile/SPA clients |
| Soft deletes | Custom `SoftDeletable` concern | Simple `deleted_at` column with default_scope |
| Background jobs | Solid Queue | Rails 8 default, no Redis needed |
| Caching | Solid Cache | Rails 8 default, DB-backed |
| WebSockets | Solid Cable | Rails 8 default for Turbo Streams |
| CSS | Tailwind CSS 4 | via tailwindcss-rails gem |
| Testing | RSpec + FactoryBot + Capybara | Industry standard for Rails |
| Charts | Chartkick + Groupdate | Simple chart generation in views |
| Pagination | Pagy | Fastest Rails pagination |
| Search | Custom parser + Ransack | Anki syntax parsed to ActiveRecord queries |
| File storage | Active Storage | Local dev, S3 production |

---

## Gemfile (Key Gems)

```ruby
# Core
gem "rails", "~> 8.0"
gem "pg", "~> 1.5"
gem "puma", ">= 6.0"
gem "solid_queue", "solid_cache", "solid_cable"
gem "propshaft", "turbo-rails", "stimulus-rails", "importmap-rails"
gem "tailwindcss-rails"

# Auth
gem "devise", "~> 4.9"
gem "devise-jwt", "~> 0.12"

# Features
gem "pagy", "~> 9.0"              # Pagination
gem "ransack", "~> 4.0"           # Browser filtering
gem "chartkick", "~> 5.0"         # Statistics charts
gem "groupdate", "~> 6.0"         # Date grouping for stats
gem "rubyzip", "~> 2.3"           # APKG import/export
gem "mini_magick", "~> 5.0"       # Image processing
gem "mission_control-jobs"         # Solid Queue UI

# Test
gem "rspec-rails", "factory_bot_rails", "faker"
gem "shoulda-matchers", "capybara", "cuprite"
gem "simplecov", "bullet", "brakeman"
```

---

## Directory Structure

```
app/
  controllers/
    concerns/          # authenticatable, ownership_verifiable, paginatable
    api/v1/            # JWT-authenticated JSON API controllers
    decks_controller.rb
    notes_controller.rb
    note_types_controller.rb
    cards_controller.rb
    study_sessions_controller.rb
    reviews_controller.rb
    statistics_controller.rb
    user_preferences_controller.rb
    media_controller.rb
    filtered_decks_controller.rb
    ...
  models/
    concerns/          # soft_deletable, user_scoped, jsonb_accessors
    user.rb, deck.rb, note_type.rb, note.rb, card.rb, review.rb
    medium.rb, note_medium.rb, user_preference.rb, ...
  services/
    scheduling/        # sm2_scheduler, fsrs_scheduler, scheduler_factory
    study/             # session_manager, card_queue_builder, answer_processor,
                       # sibling_burier, daily_limit_tracker, leech_detector
    cards/             # generator, template_renderer, position_assigner
    search/            # query_parser, executor
    import_export/     # csv_importer, apkg_importer, csv_exporter, apkg_exporter
    users/             # setup_service (default deck, note types, preferences)
  jobs/                # unbury_cards, backup_collection, fsrs_optimize, etc.
  views/               # Hotwire views with Turbo Frames/Streams
  javascript/controllers/  # Stimulus: study, deck_tree, search, browser, etc.
```

---

## Phase 1: Project Bootstrap & Authentication (Week 1-2)

### Goal
Set up Rails 8 app, configure PostgreSQL enums, implement Devise auth, create dashboard shell.

### Migrations
1. `CreateEnums` - `card_state`, `review_type`, `theme_type`, `scheduler_type` via `execute`
2. `DeviseCreateUsers` - users table with Devise fields + `last_login_at`, `deleted_at`
3. `CreateJwtDenylist` - JWT token revocation table
4. `CreateUserPreferences` - 30+ preference columns matching schema.up.sql

### Models
- `User` (Devise: database_authenticatable, registerable, recoverable, confirmable, jwt_authenticatable)
- `UserPreference` (belongs_to :user, enum :theme)
- `JwtDenylist` (JWT revocation)

### Services
- `Users::SetupService` - after user creation: create default preference, default deck, default note types (Basic, Basic+Reversed, Cloze)

### Key Files
- `config/application.rb`: `config.active_record.schema_format = :sql`
- `config/routes.rb`: devise_for :users, root "dashboard#show", API namespace
- `app/controllers/dashboard_controller.rb`
- `app/controllers/user_preferences_controller.rb`

### Deliverables
- User registration with email confirmation
- Login/logout with Devise sessions
- JWT auth endpoint at `/api/v1/auth/*`
- User preferences edit page (theme, language, etc.)
- Empty dashboard page

---

## Phase 2: Decks & Note Types CRUD (Week 3-4)

### Goal
Implement deck hierarchy and note types with fields/templates editor.

### Migrations
5. `CreateDecks` - with partial unique indexes for name uniqueness per hierarchy level
6. `CreateNoteTypes` - fields_json, card_types_json, templates_json (JSONB)
7. `CreateDeckOptionsPresets` - reusable deck configuration presets

### Models
- `Deck` (SoftDeletable, belongs_to :parent, has_many :children, store_accessor for options_json)
  - Methods: `ancestors`, `descendants`, `full_name` (join with "::")
  - Scopes: `roots`, `ordered`
- `NoteType` (SoftDeletable, fields/card_types/templates via JSONB)
  - Methods: `fields`, `card_types`, `field_names`
- `DeckOptionsPreset`

### Controllers
- `DecksController` - full CRUD with hierarchy, Turbo Stream for tree updates
- `NoteTypesController` - CRUD with template preview
- `DeckOptionsPresetsController`

### Views
- Deck tree with expand/collapse (Stimulus: `deck_tree_controller.js`)
- Note type fields editor with add/remove/reorder (Stimulus: `fields_editor_controller.js`)
- Template editor with live preview (Stimulus: `template_editor_controller.js`)

### Seeds
Default note types: Basic, Basic (and reversed), Basic (optional reversed), Basic (type in answer), Cloze

---

## Phase 3: Notes, Cards & Browser (Week 5-7)

### Goal
Note creation with automatic card generation, full browser interface.

### Migrations
8. `CreateNotes` - guid, fields_json, tags array, marked; GUID format CHECK constraint; GIN indexes on tags and full-text search
9. `CreateCards` - state enum, due/interval/ease/lapses/reps, flag, suspended/buried, FSRS fields; CHECK constraints; study query index
10. `CreateReviews` - rating, interval, ease, time_ms, type enum
11. `CreateDeletionsLog` - object_type, object_id, object_data JSONB
12. `CreateBrowserConfigs` - visible_columns array, column_widths JSONB, sort
13. `CreateFlagNames` - user_id, flag_number (1-7), name
14. `CreateSavedSearches` - name, search_query

### Models
- `Note` (SoftDeletable, before_validation: generate_guid, after_create: generate_cards, after_update: regenerate_cards)
  - Validates first field present, GUID format
  - Scopes: `tagged(tag)`, `marked`
- `Card` (enum :state, scopes: `active`, `due_for_review(ts)`, `due_for_learning(ts)`, `new_cards`, `siblings_of(card)`)
  - Validates: ease >= 1300, interval >= 0, flag 0-7
  - Method: `leech?(threshold)`
- `Review` (enum :review_type, validates rating 1-4, time_ms > 0)

### Services
- `Cards::Generator` - generates cards from note based on note_type card_types
- `Cards::TemplateRenderer` - renders front/back templates with:
  - Field replacements `{{FieldName}}`
  - Conditionals `{{#Field}}...{{/Field}}`, `{{^Field}}...{{/Field}}`
  - Cloze deletions `{{c1::text::hint}}`
  - Special fields: `{{FrontSide}}`, `{{Tags}}`, `{{Deck}}`, `{{Type}}`

### Browser Interface (most complex view)
- Left sidebar: deck tree, tags, saved searches (Turbo Frame)
- Top: search bar with Anki syntax
- Main: sortable table of notes/cards (Turbo Frame for pagination)
- Bottom: note preview/edit pane (Turbo Frame)
- Card operations: flag, bury, suspend, reset, set_due (Turbo Streams)
- Stimulus controllers: `browser_controller.js`, `search_controller.js`, `tag_input_controller.js`

---

## Phase 4: Study System & SM-2 Algorithm (Week 8-10)

### Goal
Core study experience with SM-2 scheduling, card queuing, daily limits, leech detection.

### Services
- **`Scheduling::Sm2Scheduler`** - Full SM-2 implementation:
  - `answer_new(rating)`: Learning steps -> graduate on Good/Easy
  - `answer_learning(rating)`: Step progression, return to step 0 on Again
  - `answer_review(rating)`: Interval calculation with ease factor, fuzz factor
  - `answer_relearning(rating)`: Relearning steps -> return to review
  - Ease: Again -200, Hard -150, Good unchanged, Easy +150 (min 1300)
  - Fuzz factor: ~25% randomization on intervals >= 3 days
  - Hard interval: current * 1.2 * modifier
  - Good interval: current * (ease/1000) * modifier
  - Easy interval: current * (ease/1000) * easy_bonus * modifier
  - New interval guaranteed >= previous + 1 day, capped at maximum_interval

- **`Study::SessionManager`** - Orchestrates study session
- **`Study::CardQueueBuilder`** - Build queue: learning due -> review due -> new cards (respecting daily limits)
- **`Study::AnswerProcessor`** - Process answer: update card, create review, detect leech, bury siblings
- **`Study::SiblingBurier`** - Auto-bury sibling cards (configurable)
- **`Study::DailyLimitTracker`** - Track new/review counts per day
- **`Study::LeechDetector`** - Detect at threshold (default 8 lapses), auto-tag, optional auto-suspend

### Controller
- `StudySessionsController#show` - Show next card (question side)
- `StudySessionsController#show_answer` - Flip to answer side (Turbo Stream)
- `StudySessionsController#answer` - Submit rating, get next card (Turbo Stream)

### Stimulus
- `study_controller.js` - Keyboard shortcuts (Space=flip, 1-4=rate), timer tracking, Turbo Stream integration

### Background Jobs
- `UnburyCardsJob` - Recurring at day boundary per user
- `DailyResetJob` - Reset daily limit counters

### Routes
```ruby
resources :decks do
  resource :study_session, only: [:show], path: "study" do
    post :answer
    post :show_answer
    post :undo
  end
end
```

---

## Phase 5: Statistics & Deck Overview (Week 11-12)

### Goal
Statistics dashboard with charts and deck overview with card counts.

### Controller
- `StatisticsController#show` - Aggregate review data, render charts
  - Reviews per day (bar chart)
  - Review time per day
  - Retention rate (% correct by maturity)
  - Interval distribution (histogram)
  - Card state breakdown (pie)
  - Hourly breakdown (when you study)
  - Period switching (week/month/year) via Turbo Frames

### Implementation
- Use `chartkick` + `groupdate` for chart generation in views
- Cache statistics for 5 minutes (Solid Cache)
- Deck overview: query `deck_statistics` view or compute from cards table

---

## Phase 6: Media Management (Week 13-14)

### Goal
File upload/storage/reference in note fields.

### Migrations
15. `CreateMedia` - SHA-256 hash, mime_type, storage_path; unique hash per user
16. `CreateNoteMedia` - junction table with field_name

### Implementation
- Active Storage for actual file storage (local dev, S3 prod)
- `media` table for metadata/dedup layer
- SHA-256 hash computation on upload for deduplication
- Drag-and-drop upload in note editor (Stimulus: `media_upload_controller.js`)
- Supported formats: JPG, PNG, GIF, WebP, MP3, OGG, WAV, MP4, WebM (max 100MB)
- Unused media detection and cleanup (`MediaCleanupJob`)

---

## Phase 7: Advanced Search (Week 15-16)

### Goal
Full Anki search syntax in the browser.

### Services
- **`Search::QueryParser`** - Parses Anki syntax to AST:
  - Text, OR, NOT (`-`), field-specific (`front:`), tags (`tag:`), deck (`deck:`)
  - State (`is:new/due/review/learn/suspended/buried`)
  - Properties (`prop:ivl>=10`, `prop:ease>2.0`, `prop:lapses>3`)
  - Rating history (`rated:7:1`)
  - Regex (`re:\d{3}`), accent-insensitive (`nc:`)
  - Flag, date range, note/card IDs
- **`Search::Executor`** - Translates AST to ActiveRecord queries with proper joins

---

## Phase 8: FSRS Algorithm (Week 17-18)

### Goal
FSRS-5 as alternative scheduler to SM-2.

### Services
- **`Scheduling::FsrsScheduler`** - Stability, difficulty, retrievability calculation
- **`Scheduling::SchedulerFactory`** - Returns SM2 or FSRS based on deck options
- **`FsrsOptimizeJob`** - Background parameter optimization (requires 100+ reviews)

---

## Phase 9: Filtered Decks & Undo (Week 19-20)

- Filtered decks CRUD with search-based card selection
- Card temporary movement preserving `home_deck_id`
- Rebuild/empty filtered decks
- Undo/redo via `undo_history` table (max 50 ops)
- Custom study presets (increase limits, study forgotten, anticipate, etc.)

---

## Phase 10: Import/Export (Week 21-22)

- CSV import with column mapping and duplicate detection
- CSV export of selected notes
- APKG import (parse Anki SQLite + media ZIP)
- APKG export (generate SQLite + bundle media)
- Import runs as background job with progress tracking

---

## Phase 11: Backups & Sync (Week 23-24)

- Manual/automatic backup creation (Solid Queue recurring)
- Backup before destructive operations
- Backup restoration
- Retention policy cleanup job
- Sync metadata tracking
- Basic sync protocol (full upload/download)

---

## Phase 12: Shared Decks & Profiles (Week 25-26)

- Shared deck publishing (APKG generation + upload)
- Marketplace: browse, search, filter, sort
- Rating/review system
- Download and import
- Profile CRUD with collection isolation
- Profile switching
- Single AnkiWeb sync per user validation

---

## Cross-Cutting Concerns

### Model Concerns
- **`SoftDeletable`**: `default_scope { where(deleted_at: nil) }`, `soft_delete!`, `restore!`, `with_deleted`, `only_deleted`
- **`UserScoped`**: `scope :for_user, ->(user) { where(user_id: user.id) }`

### Controller Concerns
- **`OwnershipVerifiable`**: Verify `record.user_id == current_user.id`
- **`Paginatable`**: Pagy integration helper

### Background Jobs (Solid Queue)
| Job | Schedule | Purpose |
|---|---|---|
| UnburyCardsJob | Recurring (day boundary) | Unbury all buried cards |
| DailyResetJob | Recurring (day boundary) | Reset daily limit counters |
| BackupCollectionJob | Daily 3 AM | Automatic backups |
| MediaCleanupJob | Weekly | Detect unused media |
| FsrsOptimizeJob | On demand | Optimize FSRS parameters |
| CheckDatabaseJob | Weekly | Verify data integrity |

### Testing Strategy
| Layer | Tool | Target |
|---|---|---|
| Models | RSpec + Shoulda Matchers | Validations, associations, scopes, callbacks |
| Services | RSpec unit tests | Business logic, SM-2/FSRS algorithms, template rendering |
| Controllers | Request specs | HTTP status, response format, auth |
| System | Capybara + Cuprite | Study flow, browser, deck management |
| Factories | FactoryBot | All 23 models |

### I18n
- English (`en.yml`) and Brazilian Portuguese (`pt-BR.yml`)
- All user-facing strings through `I18n.t()`

---

## Critical Source Files

- `/home/felipe/Projects/rebisyon/schema.up.sql` - All 23 tables, enums, indexes, triggers, views, constraints
- `/home/felipe/Projects/rebisyon/docs/Regras de Negócio - Sistema Anki.md` - 127 business rules (especially SM-2: BR-014 to BR-021, study order: BR-022 to BR-026)
- `/home/felipe/Projects/rebisyon/docs/Backend Tickets.md` - 1100+ tickets as implementation checklist
- `/home/felipe/Projects/rebisyon/docs/Especificação API REST - Sistema Anki.md` - API spec for `/api/v1/` controllers
- `/home/felipe/Projects/rebisyon/docs/Casos de Uso - Sistema Anki.md` - 500+ use cases for acceptance criteria

---

## Verification

After each phase:
1. `bin/rails db:migrate` - migrations run cleanly
2. `bundle exec rspec` - all tests pass
3. `bin/rails s` - app starts, manual smoke test of new features
4. `bin/rails db:migrate:status` - verify migration state
5. Check `db/structure.sql` matches expected schema state
