# Schema SQL - Sistema Anki Completo

Este documento contém o schema SQL completo do banco de dados PostgreSQL para o sistema Anki.

## 1. Enums e Tipos Customizados

```sql
-- Enum para estados de cards
CREATE TYPE card_state AS ENUM ('new', 'learn', 'review', 'relearn');

-- Enum para tipos de revisão
CREATE TYPE review_type AS ENUM ('learn', 'review', 'relearn', 'cram');

-- Enum para temas
CREATE TYPE theme_type AS ENUM ('light', 'dark', 'auto');

-- Enum para algoritmos de repetição espaçada
CREATE TYPE scheduler_type AS ENUM ('sm2', 'fsrs');
```

## 2. Tabelas Principais

### 2.1 Tabela: users

```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Índices
CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_created_at ON users(created_at);

-- Comentários
COMMENT ON TABLE users IS 'Tabela de usuários do sistema';
COMMENT ON COLUMN users.email IS 'Email único do usuário';
COMMENT ON COLUMN users.password_hash IS 'Hash da senha (bcrypt/argon2)';
COMMENT ON COLUMN users.email_verified IS 'Indica se email foi verificado';
COMMENT ON COLUMN users.deleted_at IS 'Soft delete - NULL se ativo';
```

### 2.2 Tabela: decks

```sql
CREATE TABLE decks (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    parent_id BIGINT REFERENCES decks(id) ON DELETE SET NULL,
    options_json JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraint: nome único por usuário no mesmo nível hierárquico
    CONSTRAINT unique_deck_name_per_user UNIQUE (user_id, name, parent_id, deleted_at)
);

-- Índices
CREATE INDEX idx_decks_user_id ON decks(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_decks_parent_id ON decks(parent_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_decks_name ON decks(name) WHERE deleted_at IS NULL;
CREATE INDEX idx_decks_user_parent ON decks(user_id, parent_id) WHERE deleted_at IS NULL;

-- Comentários
COMMENT ON TABLE decks IS 'Tabela de decks (baralhos)';
COMMENT ON COLUMN decks.name IS 'Nome do deck (pode conter :: para hierarquia)';
COMMENT ON COLUMN decks.parent_id IS 'ID do deck pai (NULL para decks raiz)';
COMMENT ON COLUMN decks.options_json IS 'Opções do deck em JSON (preset, limites, etc.)';
```

### 2.3 Tabela: note_types

```sql
CREATE TABLE note_types (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    fields_json JSONB NOT NULL DEFAULT '[]',
    card_types_json JSONB NOT NULL DEFAULT '[]',
    templates_json JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraint: nome único por usuário
    CONSTRAINT unique_note_type_name_per_user UNIQUE (user_id, name, deleted_at)
);

-- Índices
CREATE INDEX idx_note_types_user_id ON note_types(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_note_types_name ON note_types(name) WHERE deleted_at IS NULL;

-- Comentários
COMMENT ON TABLE note_types IS 'Tabela de tipos de nota (note types)';
COMMENT ON COLUMN note_types.fields_json IS 'Array de campos: [{"name": "Front", "ord": 0}, ...]';
COMMENT ON COLUMN note_types.card_types_json IS 'Array de card types: [{"name": "Forward", "ord": 0}, ...]';
COMMENT ON COLUMN note_types.templates_json IS 'Templates: {"Front": "...", "Back": "...", "Styling": "..."}';
```

### 2.4 Tabela: notes

```sql
CREATE TABLE notes (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    guid VARCHAR(36) NOT NULL UNIQUE,
    note_type_id BIGINT NOT NULL REFERENCES note_types(id) ON DELETE RESTRICT,
    fields_json JSONB NOT NULL DEFAULT '{}',
    tags TEXT[] NOT NULL DEFAULT '{}',
    marked BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraint: primeiro campo deve ser único por note type (para duplicatas)
    CONSTRAINT check_guid_format CHECK (guid ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
);

-- Índices
CREATE INDEX idx_notes_user_id ON notes(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_notes_note_type_id ON notes(note_type_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_notes_guid ON notes(guid);
CREATE INDEX idx_notes_marked ON notes(marked) WHERE deleted_at IS NULL;
CREATE INDEX idx_notes_tags ON notes USING GIN(tags) WHERE deleted_at IS NULL;
CREATE INDEX idx_notes_created_at ON notes(created_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_notes_updated_at ON notes(updated_at) WHERE deleted_at IS NULL;

-- Índice full-text para busca
CREATE INDEX idx_notes_fields_fts ON notes USING GIN(to_tsvector('portuguese', fields_json::text)) WHERE deleted_at IS NULL;

-- Comentários
COMMENT ON TABLE notes IS 'Tabela de notes (notas)';
COMMENT ON COLUMN notes.guid IS 'GUID único global para sincronização';
COMMENT ON COLUMN notes.fields_json IS 'Campos da note: {"Front": "...", "Back": "..."}';
COMMENT ON COLUMN notes.tags IS 'Array de tags da note';
COMMENT ON COLUMN notes.marked IS 'Indica se note está marcada (tag "marked")';
```

### 2.5 Tabela: cards

```sql
CREATE TABLE cards (
    id BIGSERIAL PRIMARY KEY,
    note_id BIGINT NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
    card_type_id INTEGER NOT NULL DEFAULT 0,
    deck_id BIGINT NOT NULL REFERENCES decks(id) ON DELETE RESTRICT,
    home_deck_id BIGINT REFERENCES decks(id) ON DELETE SET NULL,
    due BIGINT NOT NULL DEFAULT 0,
    interval INTEGER NOT NULL DEFAULT 0,
    ease INTEGER NOT NULL DEFAULT 2500,
    lapses INTEGER NOT NULL DEFAULT 0,
    reps INTEGER NOT NULL DEFAULT 0,
    state card_state NOT NULL DEFAULT 'new',
    position INTEGER NOT NULL DEFAULT 0,
    flag SMALLINT NOT NULL DEFAULT 0,
    suspended BOOLEAN NOT NULL DEFAULT FALSE,
    buried BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Campos específicos do FSRS
    stability REAL,
    difficulty REAL,
    last_review_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT check_flag_range CHECK (flag >= 0 AND flag <= 7),
    CONSTRAINT check_ease_range CHECK (ease >= 1300),
    CONSTRAINT check_interval_non_negative CHECK (interval >= 0),
    CONSTRAINT check_due_valid CHECK (due >= 0),
    CONSTRAINT check_home_deck CHECK (home_deck_id IS NULL OR home_deck_id != deck_id)
);

-- Índices
CREATE INDEX idx_cards_note_id ON cards(note_id);
CREATE INDEX idx_cards_deck_id ON cards(deck_id);
CREATE INDEX idx_cards_home_deck_id ON cards(home_deck_id) WHERE home_deck_id IS NOT NULL;
CREATE INDEX idx_cards_due ON cards(due) WHERE suspended = FALSE AND buried = FALSE;
CREATE INDEX idx_cards_state ON cards(state) WHERE suspended = FALSE AND buried = FALSE;
CREATE INDEX idx_cards_flag ON cards(flag) WHERE flag > 0;
CREATE INDEX idx_cards_suspended ON cards(suspended) WHERE suspended = TRUE;
CREATE INDEX idx_cards_buried ON cards(buried) WHERE buried = TRUE;
CREATE INDEX idx_cards_position ON cards(position) WHERE state = 'new';
CREATE INDEX idx_cards_deck_state_due ON cards(deck_id, state, due) WHERE suspended = FALSE AND buried = FALSE;
CREATE INDEX idx_cards_fsrs_stability ON cards(stability) WHERE stability IS NOT NULL;
CREATE INDEX idx_cards_created_at ON cards(created_at);

-- Comentários
COMMENT ON TABLE cards IS 'Tabela de cards (cartões)';
COMMENT ON COLUMN cards.due IS 'Timestamp (milliseconds) ou posição na fila (para new cards)';
COMMENT ON COLUMN cards.interval IS 'Intervalo em dias (ou segundos negativos para learning)';
COMMENT ON COLUMN cards.ease IS 'Ease factor em permille (2500 = 2.5x)';
COMMENT ON COLUMN cards.card_type_id IS 'ID do card type (ordinal do card type no note type)';
COMMENT ON COLUMN cards.position IS 'Posição na fila de novos cards';
COMMENT ON COLUMN cards.flag IS 'Flag colorida (0-7, 0 = sem flag)';
COMMENT ON COLUMN cards.stability IS 'Stability do FSRS (em dias)';
COMMENT ON COLUMN cards.difficulty IS 'Difficulty do FSRS (0.0-1.0)';
COMMENT ON COLUMN cards.home_deck_id IS 'Deck original (home deck) quando card está em filtered deck';
```

### 2.6 Tabela: reviews

```sql
CREATE TABLE reviews (
    id BIGSERIAL PRIMARY KEY,
    card_id BIGINT NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
    rating SMALLINT NOT NULL,
    interval INTEGER NOT NULL,
    ease INTEGER NOT NULL,
    time_ms INTEGER NOT NULL,
    type review_type NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT check_rating_range CHECK (rating >= 1 AND rating <= 4),
    CONSTRAINT check_time_ms_positive CHECK (time_ms > 0),
    CONSTRAINT check_interval_valid CHECK (interval != 0)
);

-- Índices
CREATE INDEX idx_reviews_card_id ON reviews(card_id);
CREATE INDEX idx_reviews_created_at ON reviews(created_at);
CREATE INDEX idx_reviews_card_created ON reviews(card_id, created_at);
CREATE INDEX idx_reviews_type ON reviews(type);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- Comentários
COMMENT ON TABLE reviews IS 'Tabela de histórico de revisões (revlog)';
COMMENT ON COLUMN reviews.rating IS 'Rating: 1=Again, 2=Hard, 3=Good, 4=Easy';
COMMENT ON COLUMN reviews.interval IS 'Novo intervalo após revisão (dias ou segundos negativos)';
COMMENT ON COLUMN reviews.ease IS 'Novo ease factor após revisão (permille)';
COMMENT ON COLUMN reviews.time_ms IS 'Tempo gasto na revisão (milliseconds)';
COMMENT ON COLUMN reviews.type IS 'Tipo de revisão: learn, review, relearn, cram';
```

### 2.7 Tabela: media

```sql
CREATE TABLE media (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    filename VARCHAR(255) NOT NULL,
    hash VARCHAR(64) NOT NULL,
    size BIGINT NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    storage_path VARCHAR(512) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraint: hash único por usuário
    CONSTRAINT unique_media_hash_per_user UNIQUE (user_id, hash, deleted_at),
    CONSTRAINT check_size_positive CHECK (size > 0)
);

-- Índices
CREATE INDEX idx_media_user_id ON media(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_media_hash ON media(hash) WHERE deleted_at IS NULL;
CREATE INDEX idx_media_filename ON media(filename) WHERE deleted_at IS NULL;
CREATE INDEX idx_media_mime_type ON media(mime_type) WHERE deleted_at IS NULL;

-- Comentários
COMMENT ON TABLE media IS 'Tabela de arquivos de media (imagens, áudio, vídeo)';
COMMENT ON COLUMN media.hash IS 'SHA-256 hash do arquivo (para deduplicação)';
COMMENT ON COLUMN media.storage_path IS 'Caminho do arquivo no storage';
COMMENT ON COLUMN media.deleted_at IS 'Soft delete - NULL se ativo';
```

### 2.8 Tabela: note_media

```sql
CREATE TABLE note_media (
    note_id BIGINT NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
    media_id BIGINT NOT NULL REFERENCES media(id) ON DELETE CASCADE,
    field_name VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (note_id, media_id),
    
    -- Constraint: media não pode estar associada duas vezes à mesma note no mesmo campo
    CONSTRAINT unique_note_media_field UNIQUE (note_id, media_id, field_name)
);

-- Índices
CREATE INDEX idx_note_media_note_id ON note_media(note_id);
CREATE INDEX idx_note_media_media_id ON note_media(media_id);

-- Comentários
COMMENT ON TABLE note_media IS 'Tabela de junção entre notes e media';
COMMENT ON COLUMN note_media.field_name IS 'Nome do campo onde media é usada (NULL se em template)';
```

### 2.9 Tabela: sync_meta

```sql
CREATE TABLE sync_meta (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    client_id VARCHAR(255) NOT NULL,
    last_sync TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_sync_usn BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraint: um registro por usuário por cliente
    CONSTRAINT unique_user_client UNIQUE (user_id, client_id)
);

-- Índices
CREATE INDEX idx_sync_meta_user_id ON sync_meta(user_id);
CREATE INDEX idx_sync_meta_client_id ON sync_meta(client_id);
CREATE INDEX idx_sync_meta_last_sync ON sync_meta(last_sync);

-- Comentários
COMMENT ON TABLE sync_meta IS 'Tabela de metadados de sincronização';
COMMENT ON COLUMN sync_meta.client_id IS 'Identificador único do cliente/dispositivo';
COMMENT ON COLUMN sync_meta.last_sync_usn IS 'Último update sequence number sincronizado';
```

### 2.10 Tabela: user_preferences

```sql
CREATE TABLE user_preferences (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    language VARCHAR(10) NOT NULL DEFAULT 'pt-BR',
    theme theme_type NOT NULL DEFAULT 'auto',
    auto_sync BOOLEAN NOT NULL DEFAULT TRUE,
    next_day_starts_at TIME NOT NULL DEFAULT '04:00:00',
    learn_ahead_limit INTEGER NOT NULL DEFAULT 20,
    timebox_time_limit INTEGER NOT NULL DEFAULT 0,
    video_driver VARCHAR(50) NOT NULL DEFAULT 'auto',
    ui_size REAL NOT NULL DEFAULT 1.0,
    minimalist_mode BOOLEAN NOT NULL DEFAULT FALSE,
    reduce_motion BOOLEAN NOT NULL DEFAULT FALSE,
    paste_strips_formatting BOOLEAN NOT NULL DEFAULT FALSE,
    paste_images_as_png BOOLEAN NOT NULL DEFAULT FALSE,
    default_deck_behavior VARCHAR(50) NOT NULL DEFAULT 'current_deck',
    show_play_buttons BOOLEAN NOT NULL DEFAULT TRUE,
    interrupt_audio_on_answer BOOLEAN NOT NULL DEFAULT TRUE,
    show_remaining_count BOOLEAN NOT NULL DEFAULT TRUE,
    show_next_review_time BOOLEAN NOT NULL DEFAULT FALSE,
    spacebar_answers_card BOOLEAN NOT NULL DEFAULT TRUE,
    ignore_accents_in_search BOOLEAN NOT NULL DEFAULT FALSE,
    default_search_text VARCHAR(255),
    sync_audio_and_images BOOLEAN NOT NULL DEFAULT TRUE,
    periodically_sync_media BOOLEAN NOT NULL DEFAULT FALSE,
    force_one_way_sync BOOLEAN NOT NULL DEFAULT FALSE,
    self_hosted_sync_server_url VARCHAR(512),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT check_learn_ahead_limit CHECK (learn_ahead_limit >= 0),
    CONSTRAINT check_timebox_limit CHECK (timebox_time_limit >= 0),
    CONSTRAINT check_ui_size CHECK (ui_size > 0 AND ui_size <= 3.0)
);

-- Índices
CREATE INDEX idx_user_preferences_user_id ON user_preferences(user_id);

-- Comentários
COMMENT ON TABLE user_preferences IS 'Tabela de preferências globais do usuário';
COMMENT ON COLUMN user_preferences.learn_ahead_limit IS 'Limite em minutos para mostrar cards em learning antes do due';
COMMENT ON COLUMN user_preferences.timebox_time_limit IS 'Limite de tempo em minutos para timeboxing (0 = desabilitado)';
COMMENT ON COLUMN user_preferences.ui_size IS 'Multiplicador de tamanho da UI (1.0 = padrão)';
```

### 2.11 Tabela: backups

```sql
CREATE TABLE backups (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    filename VARCHAR(255) NOT NULL,
    size BIGINT NOT NULL,
    storage_path VARCHAR(512) NOT NULL,
    backup_type VARCHAR(20) NOT NULL DEFAULT 'automatic',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT check_size_positive CHECK (size > 0),
    CONSTRAINT check_backup_type CHECK (backup_type IN ('automatic', 'manual', 'pre_operation'))
);

-- Índices
CREATE INDEX idx_backups_user_id ON backups(user_id);
CREATE INDEX idx_backups_created_at ON backups(created_at);
CREATE INDEX idx_backups_user_created ON backups(user_id, created_at);

-- Comentários
COMMENT ON TABLE backups IS 'Tabela de backups do usuário';
COMMENT ON COLUMN backups.backup_type IS 'Tipo: automatic, manual, pre_operation';
```

### 2.12 Tabela: filtered_decks

```sql
CREATE TABLE filtered_decks (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    search_filter TEXT NOT NULL,
    second_filter TEXT,
    limit_cards INTEGER NOT NULL DEFAULT 20,
    order_by VARCHAR(50) NOT NULL DEFAULT 'due',
    reschedule BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_rebuild_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT check_limit_positive CHECK (limit_cards > 0)
);

-- Índices
CREATE INDEX idx_filtered_decks_user_id ON filtered_decks(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_filtered_decks_name ON filtered_decks(name) WHERE deleted_at IS NULL;

-- Comentários
COMMENT ON TABLE filtered_decks IS 'Tabela de filtered decks (custom study)';
COMMENT ON COLUMN filtered_decks.search_filter IS 'Filtro de busca principal';
COMMENT ON COLUMN filtered_decks.second_filter IS 'Segundo filtro opcional';
COMMENT ON COLUMN filtered_decks.order_by IS 'Ordem: due, random, intervals, lapses, etc.';
```

### 2.13 Tabela: deck_options_presets

```sql
CREATE TABLE deck_options_presets (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    options_json JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraint: nome único por usuário
    CONSTRAINT unique_preset_name_per_user UNIQUE (user_id, name, deleted_at)
);

-- Índices
CREATE INDEX idx_deck_options_presets_user_id ON deck_options_presets(user_id) WHERE deleted_at IS NULL;

-- Comentários
COMMENT ON TABLE deck_options_presets IS 'Tabela de presets de opções de deck';
COMMENT ON COLUMN deck_options_presets.options_json IS 'Opções do preset em JSON';
```

### 2.14 Tabela: deletions_log

```sql
CREATE TABLE deletions_log (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    object_type VARCHAR(50) NOT NULL,
    object_id BIGINT NOT NULL,
    object_data JSONB,
    deleted_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT check_object_type CHECK (object_type IN ('note', 'card', 'deck', 'note_type'))
);

-- Índices
CREATE INDEX idx_deletions_log_user_id ON deletions_log(user_id);
CREATE INDEX idx_deletions_log_object ON deletions_log(object_type, object_id);
CREATE INDEX idx_deletions_log_deleted_at ON deletions_log(deleted_at);

-- Comentários
COMMENT ON TABLE deletions_log IS 'Log de exclusões para possível recuperação';
COMMENT ON COLUMN deletions_log.object_data IS 'Dados do objeto excluído (para recuperação)';
```

### 2.15 Tabela: saved_searches

```sql
CREATE TABLE saved_searches (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    search_query TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraint: nome único por usuário
    CONSTRAINT unique_saved_search_name_per_user UNIQUE (user_id, name, deleted_at)
);

-- Índices
CREATE INDEX idx_saved_searches_user_id ON saved_searches(user_id) WHERE deleted_at IS NULL;

-- Comentários
COMMENT ON TABLE saved_searches IS 'Tabela de buscas salvas do usuário';
COMMENT ON COLUMN saved_searches.search_query IS 'Query de busca em sintaxe Anki';
```

### 2.16 Tabela: flag_names

```sql
CREATE TABLE flag_names (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    flag_number SMALLINT NOT NULL,
    name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraint: flag único por usuário
    CONSTRAINT unique_flag_per_user UNIQUE (user_id, flag_number),
    CONSTRAINT check_flag_number CHECK (flag_number >= 1 AND flag_number <= 7)
);

-- Índices
CREATE INDEX idx_flag_names_user_id ON flag_names(user_id);

-- Comentários
COMMENT ON TABLE flag_names IS 'Tabela de nomes customizados para flags';
COMMENT ON COLUMN flag_names.flag_number IS 'Número da flag (1-7)';
```

### 2.17 Tabela: browser_config

```sql
CREATE TABLE browser_config (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    visible_columns TEXT[] NOT NULL DEFAULT ARRAY['note', 'deck', 'tags', 'due', 'interval', 'ease'],
    column_widths JSONB NOT NULL DEFAULT '{}',
    sort_column VARCHAR(100),
    sort_direction VARCHAR(10) NOT NULL DEFAULT 'asc',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Índices
CREATE INDEX idx_browser_config_user_id ON browser_config(user_id);

-- Comentários
COMMENT ON TABLE browser_config IS 'Configuração do browser (colunas visíveis, ordenação)';
COMMENT ON COLUMN browser_config.visible_columns IS 'Array de nomes de colunas visíveis';
COMMENT ON COLUMN browser_config.column_widths IS 'Larguras das colunas: {"note": 200, "deck": 150}';
```

### 2.18 Tabela: undo_history

```sql
CREATE TABLE undo_history (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    operation_type VARCHAR(50) NOT NULL,
    operation_data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT check_operation_type CHECK (operation_type IN ('edit_note', 'delete_note', 'move_card', 'change_flag', 'add_tag', 'remove_tag', 'change_deck'))
);

-- Índices
CREATE INDEX idx_undo_history_user_id ON undo_history(user_id, created_at DESC);
CREATE INDEX idx_undo_history_created_at ON undo_history(created_at DESC);

-- Comentários
COMMENT ON TABLE undo_history IS 'Histórico de operações para undo/redo';
COMMENT ON COLUMN undo_history.operation_data IS 'Dados da operação para reversão';
```

### 2.19 Tabela: shared_decks

```sql
CREATE TABLE shared_decks (
    id BIGSERIAL PRIMARY KEY,
    author_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    package_path VARCHAR(512) NOT NULL,
    package_size BIGINT NOT NULL,
    download_count INTEGER NOT NULL DEFAULT 0,
    rating_average REAL DEFAULT 0.0,
    rating_count INTEGER NOT NULL DEFAULT 0,
    tags TEXT[] NOT NULL DEFAULT '{}',
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    is_public BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT check_package_size_positive CHECK (package_size > 0),
    CONSTRAINT check_rating_average CHECK (rating_average >= 0 AND rating_average <= 5)
);

-- Índices
CREATE INDEX idx_shared_decks_author_id ON shared_decks(author_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_shared_decks_category ON shared_decks(category) WHERE deleted_at IS NULL AND is_public = TRUE;
CREATE INDEX idx_shared_decks_featured ON shared_decks(is_featured) WHERE deleted_at IS NULL AND is_public = TRUE;
CREATE INDEX idx_shared_decks_downloads ON shared_decks(download_count DESC) WHERE deleted_at IS NULL AND is_public = TRUE;
CREATE INDEX idx_shared_decks_tags ON shared_decks USING GIN(tags) WHERE deleted_at IS NULL AND is_public = TRUE;
CREATE INDEX idx_shared_decks_name_fts ON shared_decks USING GIN(to_tsvector('portuguese', name || ' ' || COALESCE(description, ''))) WHERE deleted_at IS NULL AND is_public = TRUE;

-- Comentários
COMMENT ON TABLE shared_decks IS 'Tabela de decks compartilhados publicamente';
COMMENT ON COLUMN shared_decks.package_path IS 'Caminho do arquivo .apkg no storage';
COMMENT ON COLUMN shared_decks.rating_average IS 'Média de avaliações (0-5)';
```

### 2.20 Tabela: shared_deck_ratings

```sql
CREATE TABLE shared_deck_ratings (
    id BIGSERIAL PRIMARY KEY,
    shared_deck_id BIGINT NOT NULL REFERENCES shared_decks(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating SMALLINT NOT NULL,
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraint: um usuário pode avaliar um deck apenas uma vez
    CONSTRAINT unique_user_deck_rating UNIQUE (shared_deck_id, user_id),
    CONSTRAINT check_rating_range CHECK (rating >= 1 AND rating <= 5)
);

-- Índices
CREATE INDEX idx_shared_deck_ratings_deck_id ON shared_deck_ratings(shared_deck_id);
CREATE INDEX idx_shared_deck_ratings_user_id ON shared_deck_ratings(user_id);

-- Comentários
COMMENT ON TABLE shared_deck_ratings IS 'Avaliações de decks compartilhados';
```

### 2.21 Tabela: add_ons

```sql
CREATE TABLE add_ons (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    version VARCHAR(20) NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    config_json JSONB DEFAULT '{}',
    installed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraint: código único por usuário
    CONSTRAINT unique_addon_code_per_user UNIQUE (user_id, code)
);

-- Índices
CREATE INDEX idx_add_ons_user_id ON add_ons(user_id);
CREATE INDEX idx_add_ons_code ON add_ons(code);
CREATE INDEX idx_add_ons_enabled ON add_ons(user_id, enabled) WHERE enabled = TRUE;

-- Comentários
COMMENT ON TABLE add_ons IS 'Tabela de add-ons instalados pelo usuário';
COMMENT ON COLUMN add_ons.code IS 'Código único do add-on';
COMMENT ON COLUMN add_ons.config_json IS 'Configurações do add-on';
```

### 2.22 Tabela: check_database_log

```sql
CREATE TABLE check_database_log (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL DEFAULT 'completed',
    issues_found INTEGER NOT NULL DEFAULT 0,
    issues_details JSONB,
    execution_time_ms INTEGER,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT check_status CHECK (status IN ('running', 'completed', 'failed', 'corrupted')),
    CONSTRAINT check_issues_non_negative CHECK (issues_found >= 0)
);

-- Índices
CREATE INDEX idx_check_database_log_user_id ON check_database_log(user_id, created_at DESC);
CREATE INDEX idx_check_database_log_status ON check_database_log(status);

-- Comentários
COMMENT ON TABLE check_database_log IS 'Log de verificações de integridade do banco';
COMMENT ON COLUMN check_database_log.issues_details IS 'Detalhes dos problemas encontrados';
```

## 3. Estrutura JSON dos Campos

### 3.1 decks.options_json

```json
{
  "preset_id": 1,
  "new_cards_per_day": 20,
  "max_reviews_per_day": 200,
  "learning_steps": [60, 600, 86400],
  "graduating_interval": 1,
  "easy_interval": 4,
  "relearning_steps": [600],
  "minimum_interval": 1,
  "scheduler": "sm2",
  "fsrs_enabled": false,
  "desired_retention": 0.9,
  "fsrs_parameters": null,
  "interval_modifier": 1.0,
  "maximum_interval": 36500,
  "easy_bonus": 1.3,
  "hard_interval": 1.2,
  "new_interval": 0.0,
  "starting_ease": 2.5,
  "bury_new_siblings": true,
  "bury_review_siblings": true,
  "bury_interday_learning_siblings": true,
  "new_card_gather_order": "deck",
  "new_card_sort_order": "card_type",
  "new_review_order": "mix",
  "interday_learning_review_order": "mix",
  "review_sort_order": "due",
  "per_deck_daily_limits": "preset",
  "new_cards_ignore_review_limit": false,
  "limits_start_from_top": false,
  "insertion_order": "sequential",
  "day_boundary_behavior": "convert_to_days",
  "hard_button_behavior": "default",
  "leech_threshold": 8,
  "leech_action": "suspend",
  "audio_auto_play": true,
  "audio_replay_buttons": true,
  "interrupt_audio_on_answer": true,
  "dont_play_audio_automatically": false,
  "skip_question_when_replaying_answer": false,
  "max_answer_seconds": 60,
  "show_timer": false,
  "stop_timer_on_answer": false,
  "auto_advance_question_seconds": 0,
  "auto_advance_answer_seconds": 0,
  "fsrs_simulator_enabled": false,
  "fsrs_simulator_days": 365,
  "fsrs_simulator_additional_cards": 0,
  "historical_retention": null,
  "ignore_cards_reviewed_before": null,
  "optimize_all_presets": false,
  "evaluate_fsrs_parameters": false,
  "easy_days": {
    "monday": "normal",
    "tuesday": "normal",
    "wednesday": "normal",
    "thursday": "normal",
    "friday": "normal",
    "saturday": "normal",
    "sunday": "normal"
  },
  "custom_scheduling": null,
  "reschedule_cards_on_change": false
}
```

Notas:
- `custom_scheduling` contém código JavaScript para custom scheduling (pode ser NULL se não usado)
- `reschedule_cards_on_change` controla se cards devem ser rescheduled ao mudar desired retention ou parâmetros FSRS
- `per_deck_daily_limits` pode ser "preset", "this_deck" ou "today_only"
- `new_card_gather_order` pode ser: "deck", "deck_then_random_notes", "ascending_position", "descending_position", "random_notes", "random_cards"
- `new_card_sort_order` pode ser: "card_type_then_order_gathered", "order_gathered", "card_type_then_random", "random_note_then_card_type", "random"
- `review_sort_order` pode ser: "due_then_random", "due_then_deck", "deck_then_due", "ascending_intervals", "descending_intervals", "ascending_ease", "descending_ease", "relative_overdueness", "ascending_retrievability" (FSRS)
- `interday_learning_review_order` pode ser: "mix", "before", "after"
- `day_boundary_behavior` controla como steps que cruzam day boundary são tratados
- `hard_button_behavior` controla comportamento específico do botão Hard em diferentes steps
- `historical_retention` é usado para preencher gaps no histórico de revisões (FSRS)
- `ignore_cards_reviewed_before` é timestamp em ms para ignorar cards na otimização FSRS
```

### 3.2 note_types.fields_json

```json
[
  {
    "id": 1,
    "name": "Front",
    "ord": 0,
    "font": "Arial",
    "font_size": 20,
    "rtl": false,
    "sticky": false,
    "sort_field": true
  },
  {
    "id": 2,
    "name": "Back",
    "ord": 1,
    "font": "Arial",
    "font_size": 20,
    "rtl": false,
    "sticky": false,
    "sort_field": false
  }
]
```

### 3.3 note_types.card_types_json

```json
[
  {
    "id": 1,
    "name": "Forward",
    "ord": 0,
    "front_template": "{{Front}}",
    "back_template": "{{FrontSide}}\n<hr id=answer>\n{{Back}}",
    "styling": ".card { font-family: arial; font-size: 20px; }",
    "browser_appearance": "{{Front}}"
  }
]
```

### 3.4 notes.fields_json

```json
{
  "Front": "Hello",
  "Back": "Olá"
}
```

### 3.5 note_types.card_types_json - Deck Override

```json
[
  {
    "id": 1,
    "name": "Forward",
    "ord": 0,
    "front_template": "{{Front}}",
    "back_template": "{{FrontSide}}\n<hr id=answer>\n{{Back}}",
    "styling": ".card { font-family: arial; font-size: 20px; }",
    "browser_appearance": "{{Front}}",
    "deck_override_id": null
  }
]
```

Nota: `deck_override_id` é o ID do deck para onde cards deste card type devem ir, independente do deck selecionado no Add Notes.
```

## 4. Triggers e Funções

### 4.1 Trigger: Atualizar updated_at

```sql
-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger em todas as tabelas com updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_decks_updated_at BEFORE UPDATE ON decks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_note_types_updated_at BEFORE UPDATE ON note_types
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notes_updated_at BEFORE UPDATE ON notes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cards_updated_at BEFORE UPDATE ON cards
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON user_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_filtered_decks_updated_at BEFORE UPDATE ON filtered_decks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_saved_searches_updated_at BEFORE UPDATE ON saved_searches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_flag_names_updated_at BEFORE UPDATE ON flag_names
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_browser_config_updated_at BEFORE UPDATE ON browser_config
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_shared_decks_updated_at BEFORE UPDATE ON shared_decks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_shared_deck_ratings_updated_at BEFORE UPDATE ON shared_deck_ratings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_add_ons_updated_at BEFORE UPDATE ON add_ons
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### 4.2 Trigger: Gerar GUID para Notes

```sql
-- Função para gerar GUID
CREATE OR REPLACE FUNCTION generate_guid()
RETURNS VARCHAR(36) AS $$
BEGIN
    RETURN gen_random_uuid()::VARCHAR;
END;
$$ LANGUAGE plpgsql;

-- Trigger para gerar GUID automaticamente
CREATE OR REPLACE FUNCTION set_note_guid()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.guid IS NULL OR NEW.guid = '' THEN
        NEW.guid = generate_guid();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_notes_guid BEFORE INSERT ON notes
    FOR EACH ROW EXECUTE FUNCTION set_note_guid();
```

### 4.3 Trigger: Log de Deletions

```sql
-- Função para logar exclusões de notes
CREATE OR REPLACE FUNCTION log_note_deletion()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
        INSERT INTO deletions_log (user_id, object_type, object_id, object_data)
        VALUES (
            OLD.user_id,
            'note',
            OLD.id,
            jsonb_build_object(
                'guid', OLD.guid,
                'note_type_id', OLD.note_type_id,
                'fields', OLD.fields_json,
                'tags', OLD.tags
            )
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_notes_deletion BEFORE UPDATE ON notes
    FOR EACH ROW EXECUTE FUNCTION log_note_deletion();
```

### 4.4 Função: Calcular Due Cards

```sql
-- Função para contar cards due de um deck
CREATE OR REPLACE FUNCTION count_due_cards(p_deck_id BIGINT, p_timestamp BIGINT)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM cards
        WHERE deck_id = p_deck_id
          AND state = 'review'
          AND due <= p_timestamp
          AND suspended = FALSE
          AND buried = FALSE
    );
END;
$$ LANGUAGE plpgsql;
```

### 4.5 Função: Calcular New Cards

```sql
-- Função para contar novos cards de um deck
CREATE OR REPLACE FUNCTION count_new_cards(p_deck_id BIGINT)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM cards
        WHERE deck_id = p_deck_id
          AND state = 'new'
          AND suspended = FALSE
          AND buried = FALSE
    );
END;
$$ LANGUAGE plpgsql;
```

### 4.6 Função: Calcular Learning Cards

```sql
-- Função para contar cards em learning de um deck
CREATE OR REPLACE FUNCTION count_learning_cards(p_deck_id BIGINT, p_timestamp BIGINT)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM cards
        WHERE deck_id = p_deck_id
          AND state IN ('learn', 'relearn')
          AND due <= p_timestamp
          AND suspended = FALSE
          AND buried = FALSE
    );
END;
$$ LANGUAGE plpgsql;
```

## 5. Views Úteis

### 5.1 View: Deck Statistics

```sql
CREATE OR REPLACE VIEW deck_statistics AS
SELECT
    d.id AS deck_id,
    d.user_id,
    d.name AS deck_name,
    COUNT(DISTINCT c.id) FILTER (WHERE c.state = 'new' AND c.suspended = FALSE AND c.buried = FALSE) AS new_count,
    COUNT(DISTINCT c.id) FILTER (WHERE c.state IN ('learn', 'relearn') AND c.suspended = FALSE AND c.buried = FALSE) AS learning_count,
    COUNT(DISTINCT c.id) FILTER (WHERE c.state = 'review' AND c.suspended = FALSE AND c.buried = FALSE) AS review_count,
    COUNT(DISTINCT c.id) FILTER (WHERE c.suspended = TRUE) AS suspended_count,
    COUNT(DISTINCT n.id) AS notes_count
FROM decks d
LEFT JOIN cards c ON c.deck_id = d.id
LEFT JOIN notes n ON n.id = c.note_id
WHERE d.deleted_at IS NULL
GROUP BY d.id, d.user_id, d.name;
```

### 5.2 View: Card Info Extended

```sql
CREATE OR REPLACE VIEW card_info_extended AS
SELECT
    c.id,
    c.note_id,
    c.deck_id,
    c.state,
    c.due,
    c.interval,
    c.ease,
    c.lapses,
    c.reps,
    c.flag,
    c.suspended,
    c.buried,
    n.guid,
    n.note_type_id,
    n.tags,
    n.marked,
    d.name AS deck_name,
    COUNT(r.id) AS total_reviews,
    MAX(r.created_at) AS last_review_at
FROM cards c
JOIN notes n ON n.id = c.note_id
JOIN decks d ON d.id = c.deck_id
LEFT JOIN reviews r ON r.card_id = c.id
WHERE n.deleted_at IS NULL AND d.deleted_at IS NULL
GROUP BY c.id, c.note_id, c.deck_id, c.state, c.due, c.interval, c.ease, 
         c.lapses, c.reps, c.flag, c.suspended, c.buried, n.guid, 
         n.note_type_id, n.tags, n.marked, d.name;
```

### 5.3 View: Empty Cards

```sql
CREATE OR REPLACE VIEW empty_cards AS
SELECT
    c.id AS card_id,
    c.note_id,
    c.deck_id,
    n.user_id,
    n.note_type_id,
    d.name AS deck_name
FROM cards c
JOIN notes n ON n.id = c.note_id
JOIN decks d ON d.id = c.deck_id
JOIN note_types nt ON nt.id = n.note_type_id
WHERE n.deleted_at IS NULL
  AND c.suspended = FALSE
  AND (
    -- Card com front template vazio após renderização
    -- (verificação simplificada - validação completa deve ser feita na aplicação)
    (c.state = 'new' AND c.position = 0)
    OR
    -- Card gerado de note sem campos obrigatórios
    (jsonb_typeof(n.fields_json) = 'object' AND n.fields_json = '{}'::jsonb)
  );
```

### 5.4 View: Leeches

```sql
CREATE OR REPLACE VIEW leeches AS
SELECT
    c.id AS card_id,
    c.note_id,
    c.deck_id,
    n.user_id,
    c.lapses,
    d.name AS deck_name,
    nt.name AS note_type_name,
    n.tags
FROM cards c
JOIN notes n ON n.id = c.note_id
JOIN decks d ON d.id = c.deck_id
JOIN note_types nt ON nt.id = n.note_type_id
WHERE n.deleted_at IS NULL
  AND c.suspended = FALSE
  AND 'leech' = ANY(n.tags)
  AND c.lapses >= (
    SELECT (options_json->>'leech_threshold')::INTEGER
    FROM decks
    WHERE id = c.deck_id
  );
```

## 6. Constraints Adicionais

### 6.1 Check Constraints

```sql
-- Garantir que interval não seja negativo para review cards
ALTER TABLE cards ADD CONSTRAINT check_review_interval 
    CHECK (state != 'review' OR interval >= 0);

-- Garantir que due seja timestamp válido para review cards
ALTER TABLE cards ADD CONSTRAINT check_review_due 
    CHECK (state != 'review' OR due > 1000000000000); -- Timestamp em ms após 2001

-- Garantir que position seja válido apenas para new cards
ALTER TABLE cards ADD CONSTRAINT check_new_position 
    CHECK (state != 'new' OR position >= 0);
```

## 7. Índices Adicionais para Performance

### 7.1 Índices Compostos

```sql
-- Índice para queries de estudo (cards due)
CREATE INDEX idx_cards_study_query ON cards(deck_id, state, due, suspended, buried) 
    WHERE suspended = FALSE AND buried = FALSE;

-- Índice para busca de cards por note
CREATE INDEX idx_cards_note_state ON cards(note_id, state);

-- Índice para estatísticas de reviews
CREATE INDEX idx_reviews_stats ON reviews(card_id, type, rating, created_at);

-- Índice para sincronização
CREATE INDEX idx_notes_sync ON notes(user_id, updated_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_cards_sync ON cards(note_id, updated_at);
CREATE INDEX idx_decks_sync ON decks(user_id, updated_at) WHERE deleted_at IS NULL;
```

### 7.2 Índices Parciais

```sql
-- Índices apenas para registros ativos (não deletados)
CREATE INDEX idx_notes_active ON notes(user_id, note_type_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_decks_active ON decks(user_id, parent_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_media_active ON media(user_id, mime_type) WHERE deleted_at IS NULL;
```

## 8. Sequências e Auto-incremento

Todas as tabelas usam `BIGSERIAL` que automaticamente cria sequências. Para resetar sequências após importação de dados:

```sql
-- Função para resetar sequências
CREATE OR REPLACE FUNCTION reset_sequences()
RETURNS void AS $$
DECLARE
    seq_name TEXT;
    max_id BIGINT;
BEGIN
    FOR seq_name IN 
        SELECT sequence_name 
        FROM information_schema.sequences 
        WHERE sequence_schema = 'public'
    LOOP
        EXECUTE format('SELECT COALESCE(MAX(id), 0) FROM %I', 
            REPLACE(seq_name, '_id_seq', ''));
        GET DIAGNOSTICS max_id = ROW_COUNT;
        EXECUTE format('SELECT setval(%L, %s)', seq_name, max_id + 1);
    END LOOP;
END;
$$ LANGUAGE plpgsql;
```

## 9. Comentários Gerais

```sql
-- Comentários sobre o schema
COMMENT ON SCHEMA public IS 'Schema principal do sistema Anki';

-- Comentários sobre relacionamentos
COMMENT ON CONSTRAINT cards_note_id_fkey ON cards IS 
    'Cascade delete: excluir note exclui todos os cards relacionados';

COMMENT ON CONSTRAINT cards_deck_id_fkey ON cards IS 
    'Restrict delete: não permite excluir deck com cards';

COMMENT ON CONSTRAINT notes_note_type_id_fkey ON notes IS 
    'Restrict delete: não permite excluir note type com notes';
```

## 10. Migrations e Versionamento

### 10.1 Tabela de Versionamento

```sql
CREATE TABLE schema_migrations (
    version BIGINT PRIMARY KEY,
    applied_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description TEXT
);

-- Inserir versão inicial
INSERT INTO schema_migrations (version, description) 
VALUES (1, 'Initial schema');
```

## 11. Considerações de Performance

### 11.1 Particionamento (Futuro)

Para coleções muito grandes, considerar particionamento por `user_id`:

```sql
-- Exemplo de particionamento por user_id (para implementação futura)
-- CREATE TABLE cards_partitioned (
--     LIKE cards INCLUDING ALL
-- ) PARTITION BY HASH (user_id);
```

### 11.2 Vacuum e Analyze

```sql
-- Configurar autovacuum para tabelas grandes
ALTER TABLE reviews SET (
    autovacuum_vacuum_scale_factor = 0.1,
    autovacuum_analyze_scale_factor = 0.05
);

ALTER TABLE cards SET (
    autovacuum_vacuum_scale_factor = 0.1,
    autovacuum_analyze_scale_factor = 0.05
);
```

## 12. Segurança

### 12.1 Row Level Security (RLS)

```sql
-- Habilitar RLS
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE decks ENABLE ROW LEVEL SECURITY;

-- Política: usuários só veem seus próprios dados
CREATE POLICY notes_user_isolation ON notes
    FOR ALL
    USING (user_id = current_setting('app.user_id')::BIGINT);

CREATE POLICY cards_user_isolation ON cards
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM notes n 
            WHERE n.id = cards.note_id 
            AND n.user_id = current_setting('app.user_id')::BIGINT
        )
    );

CREATE POLICY decks_user_isolation ON decks
    FOR ALL
    USING (user_id = current_setting('app.user_id')::BIGINT);
```

## Resumo do Schema

### Tabelas Principais (23)
1. `users` - Usuários do sistema
2. `decks` - Decks (baralhos)
3. `note_types` - Tipos de nota
4. `notes` - Notes (notas)
5. `cards` - Cards (cartões)
6. `reviews` - Histórico de revisões
7. `media` - Arquivos de media
8. `note_media` - Junção notes-media
9. `sync_meta` - Metadados de sincronização
10. `user_preferences` - Preferências globais
11. `backups` - Backups do usuário
12. `filtered_decks` - Filtered decks
13. `deck_options_presets` - Presets de opções
14. `deletions_log` - Log de exclusões
15. `saved_searches` - Buscas salvas
16. `flag_names` - Nomes customizados de flags
17. `browser_config` - Configuração do browser
18. `undo_history` - Histórico de undo/redo
19. `shared_decks` - Decks compartilhados
20. `shared_deck_ratings` - Avaliações de decks compartilhados
21. `add_ons` - Add-ons instalados
22. `check_database_log` - Log de verificações de integridade
23. `profiles` - Perfis (profiles) do usuário

### Tipos Customizados (4)
- `card_state` - Estados de cards
- `review_type` - Tipos de revisão
- `theme_type` - Tipos de tema
- `scheduler_type` - Tipos de scheduler

### Índices
- **Primary Keys**: 23
- **Foreign Keys**: 31+
- **Índices de Performance**: 42+
- **Índices Full-Text**: 2 (notes, shared_decks)
- **Índices GIN**: 4 (tags, full-text, shared_decks tags, shared_decks full-text)

### Triggers
- Atualização automática de `updated_at`
- Geração automática de GUID
- Log de exclusões

### Views
- `deck_statistics` - Estatísticas de decks
- `card_info_extended` - Informações estendidas de cards
- `empty_cards` - Cards vazios para limpeza
- `leeches` - Cards marcados como leeches

### Estruturas JSON Documentadas
- `decks.options_json` - Opções completas do deck (incluindo custom_scheduling, easy_days, FSRS, Per-Deck Daily Limits, Display Order avançado, Timers, FSRS Simulator)
- `note_types.fields_json` - Campos do note type
- `note_types.card_types_json` - Card types com templates (incluindo deck_override_id)
- `notes.fields_json` - Campos da note

Este schema suporta todas as funcionalidades do sistema Anki e está otimizado para performance e escalabilidade.
