# Sistema Anki Completo - Backend e Frontend

## Visão Geral da Arquitetura

O sistema será construído com arquitetura de microserviços/modular, separando claramente backend e frontend:

```javascript
┌─────────────┐
│   Frontend  │  React + TypeScript
│   (React)   │  └─ Web App
└──────┬──────┘
       │ HTTP/REST API
┌──────▼──────┐
│   Backend   │  Go + PostgreSQL
│    (Go)     │  └─ API REST + WebSocket
└──────┬──────┘
       │
┌──────▼──────┐
│  PostgreSQL │  Banco de dados principal
└─────────────┘
```



## Estrutura do Projeto

```javascript
anki-system/
├── backend/              # Servidor Go
│   ├── cmd/
│   │   └── server/       # Entry point do servidor
│   ├── internal/
│   │   ├── api/         # Handlers HTTP
│   │   ├── domain/      # Entidades e lógica de negócio
│   │   ├── repository/  # Camada de acesso a dados
│   │   ├── service/     # Lógica de aplicação
│   │   ├── scheduler/   # Algoritmos SM-2 e FSRS
│   │   └── sync/        # Sincronização
│   ├── pkg/             # Pacotes compartilhados
│   └── migrations/      # Migrations do banco
├── frontend/            # Aplicação React
│   ├── src/
│   │   ├── components/  # Componentes React
│   │   ├── pages/       # Páginas/rotas
│   │   ├── services/    # Cliente API
│   │   ├── store/       # Estado global (Redux/Zustand)
│   │   └── utils/       # Utilitários
│   └── public/          # Assets estáticos
└── docs/                # Documentação
```



## Componentes Principais

### 1. Backend (Go)

#### 1.1 Modelos de Dados (Domain)

**Note (Nota)**

- ID, GUID, NoteTypeID, Fields (JSON), Tags, Created, Modified, Marked (boolean)

**Card (Cartão)**

- ID, NoteID, CardTypeID, DeckID, Due, Interval, Ease, Lapses, Reps, State (new/learn/review/relearn), Flag (0-7), Suspended, Buried

**Deck (Baralho)**

- ID, Name, ParentID (hierarquia), Options (JSON), Created, Modified

**NoteType (Tipo de Nota)**

- ID, Name, Fields (array), CardTypes (array), Templates (JSON)

**Review (Revisão)**

- ID, CardID, Rating (1-4), Interval, Ease, Time, Type (learn/review/relearn)

**Media**

- ID, Filename, Hash, Size, MimeType

**User Preferences**

- ID, UserID, Language, Theme, AutoSync, NextDayStartsAt, LearnAheadLimit, TimeboxTimeLimit, etc.

#### 1.2 Algoritmos de Repetição Espaçada

**Scheduler Service**

- Implementar SM-2 (SuperMemo 2) - algoritmo legado do Anki
- Implementar FSRS (Free Spaced Repetition Scheduler) - algoritmo moderno
- Permitir escolha entre algoritmos por deck/preset
- Otimização de parâmetros FSRS baseada em histórico

**Cálculo de Intervalos**

- Learning steps (1m, 10m, 1d)
- Graduating interval
- Easy interval
- Lapse handling (relearning steps)
- Interval modifier
- Maximum interval

#### 1.3 API REST

**Endpoints Principais:**

```javascript
# Autenticação
POST   /api/auth/register
POST   /api/auth/login
POST   /api/auth/refresh
DELETE /api/auth/logout

# Decks
GET    /api/decks
POST   /api/decks
GET    /api/decks/:id
PUT    /api/decks/:id
DELETE /api/decks/:id
GET    /api/decks/:id/options
PUT    /api/decks/:id/options

# Notes
GET    /api/notes
POST   /api/notes
GET    /api/notes/:id
PUT    /api/notes/:id
DELETE /api/notes/:id

# Cards
GET    /api/cards
GET    /api/cards/:id
GET    /api/cards/:id/info       # Informações detalhadas do card
GET    /api/cards/study/:deckId  # Cards para estudo
POST   /api/cards/:id/review     # Registrar revisão
POST   /api/cards/:id/flag       # Adicionar/remover flag
POST   /api/cards/:id/bury       # Enterrar card
POST   /api/cards/:id/suspend    # Suspender card
POST   /api/cards/:id/reset      # Resetar card
POST   /api/cards/:id/set-due    # Definir data de vencimento
GET    /api/cards/leeches        # Cards identificados como leeches

# Study Session
GET    /api/study/deck/:id/overview
POST   /api/study/start/:deckId
GET    /api/study/next-card
POST   /api/study/answer
POST   /api/study/auto-advance   # Ativar/desativar auto advance
POST   /api/study/timebox        # Configurar timeboxing

# Note Types
GET    /api/note-types
POST   /api/note-types
GET    /api/note-types/:id
PUT    /api/note-types/:id
DELETE /api/note-types/:id

# Media
POST   /api/media/upload
GET    /api/media/:id
DELETE /api/media/:id
GET    /api/media/check           # Verificar media não utilizada

# Statistics
GET    /api/stats/deck/:id
GET    /api/stats/collection
GET    /api/stats/card/:id

# Search
GET    /api/search?q=...
POST   /api/search/advanced

# Sync
POST   /api/sync/upload
POST   /api/sync/download
GET    /api/sync/status

# Import/Export
POST   /api/import/text
POST   /api/import/apkg
GET    /api/export/deck/:id
GET    /api/export/collection

# Preferences
GET    /api/preferences
PUT    /api/preferences

# Backups
GET    /api/backups
POST   /api/backups/create
POST   /api/backups/:id/restore
DELETE /api/backups/:id

# Filtered Decks
POST   /api/filtered-decks
GET    /api/filtered-decks/:id
PUT    /api/filtered-decks/:id
DELETE /api/filtered-decks/:id
POST   /api/filtered-decks/:id/rebuild
```



#### 1.4 Sincronização

**Sync Service**

- Sincronização bidirecional de dados
- Detecção e resolução de conflitos
- Sincronização de media
- Versionamento de objetos (notes, cards, decks)
- Suporte a múltiplos dispositivos

#### 1.5 Media Handling

**Media Service**

- Upload e armazenamento de imagens, áudio e vídeo
- Geração de thumbnails
- Validação de formatos
- Limpeza de media não utilizada
- Suporte a LaTeX (geração de imagens)
- Suporte a MathJax (renderização no navegador)
- Audio replay buttons
- Video playback

#### 1.6 Flags e Leeches

**Flags System**

- 7 flags coloridas (0-7) para cards
- Flags a nível de card (não note)
- Busca por flag: `flag:1`, `flag:2`, etc.
- Renomeação de flags

**Leeches System**

- Detecção automática de cards com muitas falhas (threshold configurável)
- Tag automática "leech"
- Suspensão automática opcional
- Alertas periódicos (metade do threshold)
- Endpoint para listar leeches

#### 1.7 Preferences Globais

**User Preferences**

- Idioma da interface
- Tema (dark/light/auto)
- Auto sync on open/close
- Next day starts at (horário)
- Learn ahead limit
- Timebox time limit
- Video driver (software/OpenGL/ANGLE)
- UI size
- Distractions (hide bars, minimalist mode)
- Paste behavior
- Search settings

#### 1.8 Backups

**Backup System**

- Backups automáticos periódicos (configurável)
- Backups manuais
- Retenção de backups (diários, semanais, mensais)
- Restauração de backups
- Backup antes de operações destrutivas
- Export como .colpkg para backup completo

### 2. Frontend (React)

#### 2.1 Páginas Principais

**Deck List**

- Lista de decks hierárquica
- Contadores (New, Learning, Review)
- Ações: Study, Options, Export, Delete

**Study Screen**

- Exibição de card (frente/verso)
- Botões de resposta (Again, Hard, Good, Easy)
- Timer (internal e on-screen)
- Progresso da sessão
- Auto advance (avanço automático)
- Timeboxing (notificações periódicas)
- Ações: Edit, Flag, Bury, Suspend, Reset, Set Due Date, Card Info
- Audio replay buttons
- Type in answer (verificação de resposta digitada)

**Add/Edit Note**

- Editor de campos
- Seleção de Note Type
- Seleção de Deck
- Tags
- Media (imagens, áudio)
- Preview de cards

**Browse**

- Tabela de cards/notes
- Busca avançada
- Filtros
- Edição em lote
- Export

**Statistics**

- Gráficos de performance
- Retention rates
- Review counts
- Time spent
- Card intervals distribution

**Settings**

- Preferences globais (idioma, tema, sync, timers, etc.)
- Deck options
- Note types management
- Sync settings
- Backup management (criar, restaurar, listar)

#### 2.2 Componentes Reutilizáveis

- CardRenderer (renderização de cards com templates, TTS, Ruby, RTL)
- MediaViewer (imagens, áudio, vídeo, LaTeX, MathJax)
- SearchBar (busca com sintaxe Anki)
- TagInput
- DeckTree
- StatisticsChart
- Editor (rich text editor com suporte a HTML)
- FlagSelector (seletor de flags coloridas)
- CardInfoDialog (informações detalhadas do card)
- TypeAnswerInput (input com verificação)
- AudioPlayer (player de áudio com controles)

#### 2.3 Estado Global

Usar Redux Toolkit ou Zustand para:

- Decks state
- Study session state
- User preferences
- Sync status
- UI state

### 3. Banco de Dados (PostgreSQL)

#### 3.1 Schema Principal

```sql
-- Users
users (id, email, password_hash, created_at, updated_at)

-- Decks
decks (id, user_id, name, parent_id, options_json, created_at, updated_at)

-- Note Types
note_types (id, user_id, name, fields_json, card_types_json, created_at, updated_at)

-- Notes
notes (id, user_id, guid, note_type_id, fields_json, tags, marked, created_at, updated_at)

-- Cards
cards (id, note_id, card_type_id, deck_id, due, interval, ease, lapses, reps, 
       state, position, flag, suspended, buried, created_at, updated_at)

-- Reviews (Revlog)
reviews (id, card_id, rating, interval, ease, time_ms, type, created_at)

-- Media
media (id, user_id, filename, hash, size, mime_type, created_at)

-- Note Media (junction)
note_media (note_id, media_id)

-- Sync
sync_meta (id, user_id, last_sync, client_id)

-- User Preferences
user_preferences (id, user_id, language, theme, auto_sync, next_day_starts_at, 
                  learn_ahead_limit, timebox_time_limit, created_at, updated_at)

-- Backups
backups (id, user_id, filename, size, created_at)
```



#### 3.2 Índices

- Índices em foreign keys
- Índice em `cards.due` para queries de estudo
- Índice em `cards.flag` para busca por flags
- Índice em `cards.suspended` e `cards.buried` para filtros
- Índice em `notes.guid` para sincronização
- Índice em `notes.marked` para busca de marked
- Índice full-text para busca
- Índice em `reviews.card_id` e `reviews.created_at` para estatísticas

### 4. Funcionalidades Específicas do Anki

#### 4.1 Tipos de Nota

- **Basic**: Front/Back simples
- **Basic (and reversed)**: Cria 2 cards (frente→verso, verso→frente)
- **Basic (optional reversed)**: Campo adicional para criar reverso
- **Basic (type in answer)**: Campo de digitação com verificação
- **Cloze**: Deletions com {{c1::texto}}
- **Image Occlusion**: Oclusão de imagens

#### 4.2 Templates e Styling

- Sistema de templates HTML/CSS
- Field replacements: {{FieldName}}
- Conditional replacements: {{#Field}}...{{/Field}}
- Special fields: {{FrontSide}}, {{Tags}}, {{Deck}}, {{CardFlag}}, {{Type}}
- Text-to-Speech: {{tts lang:Field}}, {{tts-voices:}}
- Ruby characters: {{furigana:Field}}, {{kana:Field}}, {{kanji:Field}}
- Type in answer: {{type:Field}}, {{type:nc:Field}} (no combining)
- Styling section com CSS
- Night mode support
- Browser appearance (templates simplificados para listagem)
- Right-to-Left (RTL) support: `<div dir=rtl>`

#### 4.3 Deck Options

- New cards/day
- Maximum reviews/day
- Learning steps
- Graduating interval
- Easy interval
- Lapse settings (relearning steps, minimum interval)
- Display order (new card gather/sort, new/review order, review sort)
- Burying settings (new siblings, review siblings, interday learning siblings)
- FSRS parameters (se FSRS habilitado)
- Easy Days (ajuste por dia da semana)
- Custom scheduling (JavaScript)
- Leeches threshold e ação (suspend/tag)
- Audio settings (auto play, replay buttons)
- Timers (internal, on-screen, auto advance)

#### 4.4 Busca Avançada

Implementar sintaxe de busca do Anki:

- Simple: `dog cat`
- OR: `dog or cat`
- NOT: `-cat`
- Field: `front:dog`
- Tags: `tag:vocab`
- Deck: `deck:french`
- State: `is:new`, `is:due`, `is:review`
- Properties: `prop:ivl>=10`, `prop:due=-1`
- Regular expressions: `re:\d{3}`

### 5. Melhorias Além do Anki

#### 5.1 API REST Completa

- Documentação OpenAPI/Swagger
- Versionamento de API
- Rate limiting
- Autenticação JWT
- Webhooks para eventos
- SDKs para diferentes linguagens

#### 5.2 Performance

- Cache de queries frequentes
- Paginação em todas as listagens
- Lazy loading de media
- Otimização de queries de estudo
- Background jobs para tarefas pesadas

### 6. Implementação por Fases

**Fase 1: Core (MVP)**

- Autenticação
- CRUD de Decks, Notes, Cards
- Algoritmo SM-2 básico
- Study screen básico
- Busca simples

**Fase 2: Funcionalidades Essenciais**

- Tipos de nota (Basic, Cloze)
- Templates e styling
- Deck options
- Statistics básicas
- Media upload

**Fase 3: Funcionalidades Avançadas**

- FSRS
- Busca avançada
- Filtered decks
- Import/Export
- Sincronização

**Fase 4: Funcionalidades Complementares**

- Flags e leeches
- TTS e Ruby characters
- Type in answer
- Auto advance e timeboxing
- Backups automáticos
- Preferences globais
- Card info dialog

**Fase 5: Polimento e Melhorias**

- API REST completa
- Performance optimization
- Testes abrangentes
- Documentação
- UI/UX refinamento
- Custom scheduling
- Easy days
- Unicode normalization

### 7. Tecnologias e Ferramentas

**Backend:**

- Go 1.21+
- PostgreSQL 15+
- GORM (ORM)
- Gin/Echo (HTTP framework)
- JWT (autenticação)
- WebSocket (real-time sync)

**Frontend:**

- React 18+
- TypeScript
- Vite (build tool)
- React Router
- Redux Toolkit / Zustand
- React Query (data fetching)
- Tailwind CSS / Material-UI

**DevOps:**

- Docker & Docker Compose
- CI/CD (GitHub Actions)
- Migrations (golang-migrate)
- Testing (Go testing, Jest)

### 8. Considerações Importantes

- **Compatibilidade**: Estrutura de dados compatível com Anki para possível importação
- **Performance**: Otimizar queries de estudo (milhares de cards)
- **Escalabilidade**: Arquitetura preparada para múltiplos usuários
- **Segurança**: Validação de inputs, sanitização, rate limiting
- **Backup**: Sistema de backup automático
- **Logging**: Logging estruturado para debugging
