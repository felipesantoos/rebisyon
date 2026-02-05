# Documentação Arquitetural do Backend - Sistema Anki

Este documento descreve a arquitetura completa do backend do sistema Anki, seguindo os princípios de **Ports and Adapters (Hexagonal Architecture)**, **SOLID**, **Domain-Driven Design (DDD)** e **Repository Pattern**.

## 1. Visão Geral da Arquitetura

### 1.1 Arquitetura Hexagonal (Ports and Adapters)

A arquitetura será organizada em camadas concêntricas, onde o **domínio** está no centro, isolado de detalhes de implementação:

```mermaid
graph TB
    subgraph AdaptersDriving["Adapters (Driving)"]
        HTTP[HTTP API]
        WS[WebSocket]
    end
    
    subgraph ApplicationLayer["Application Layer"]
        AppServices["Use Cases / Services"]
    end
    
    subgraph DomainLayer["Domain Layer"]
        Entities["Entities"]
        ValueObjects["Value Objects"]
        DomainServices["Domain Services"]
        Events["Domain Events"]
    end
    
    subgraph Ports["Ports (Interfaces)"]
        RepoInterfaces["Repository Interfaces"]
        ExtInterfaces["External Interfaces"]
    end
    
    subgraph AdaptersDriven["Adapters (Driven)"]
        PostgreSQL[(PostgreSQL)]
        Storage[Storage]
    end
    
    HTTP --> AppServices
    WS --> AppServices
    AppServices --> Entities
    AppServices --> DomainServices
    Entities --> ValueObjects
    DomainServices --> RepoInterfaces
    AppServices --> RepoInterfaces
    RepoInterfaces --> PostgreSQL
    ExtInterfaces --> Storage
```

### 1.2 Por Que Arquitetura Hexagonal?

#### Benefícios da Arquitetura Hexagonal

1. **Testabilidade**: Fácil mockar dependências
   - Interfaces permitem criar mocks para testes
   - Domain isolado pode ser testado sem banco de dados
   - Services podem ser testados com repositories in-memory

2. **Flexibilidade**: Trocar implementações sem alterar lógica de negócio
   - Trocar PostgreSQL por MongoDB sem modificar domain
   - Trocar Redis por Memcached sem afetar services
   - Adicionar novos adapters (ex: GraphQL) sem mudar core

3. **Manutenibilidade**: Separação clara de responsabilidades
   - Cada camada tem uma responsabilidade bem definida
   - Mudanças em uma camada não afetam outras
   - Código organizado e fácil de navegar

4. **Independência**: Domain não depende de frameworks
   - Domain não conhece HTTP, SQL, Redis
   - Pode ser reutilizado em diferentes contextos (CLI, API, gRPC)
   - Framework pode ser trocado sem afetar business logic

5. **Escalabilidade**: Cada camada pode evoluir independentemente
   - Otimizar queries sem afetar domain
   - Adicionar cache sem modificar services
   - Escalar adapters separadamente

### 1.3 Princípios Arquiteturais

#### Dependency Inversion
- **Camadas externas dependem de interfaces definidas nas camadas internas**
- Domain define interfaces (ports)
- Infrastructure implementa interfaces (adapters)
- Application usa interfaces, não implementações concretas

#### Separation of Concerns
- **Cada camada tem responsabilidade única e bem definida**
- Domain: Business logic pura
- Application: Orquestração de use cases
- Infrastructure: Detalhes técnicos (database, HTTP, cache)
- Interfaces: Contratos entre camadas

#### Domain-Driven Design (DDD)
- **O domínio é o coração do sistema, isolado de detalhes técnicos**
- Entities representam conceitos de negócio
- Value Objects encapsulam regras de negócio
- Domain Services contêm lógica que não pertence a uma entidade
- Domain Events comunicam mudanças importantes

#### Repository Pattern
- **Abstração da persistência através de interfaces**
- Domain não conhece SQL ou banco de dados
- Múltiplas implementações possíveis (PostgreSQL, Redis, In-Memory)
- Fácil testar com repositories mockados

### 1.4 SOLID em Prática

A Arquitetura Hexagonal aplica todos os princípios SOLID:

- **Single Responsibility**: Cada camada tem um trabalho
  - Domain: Business logic
  - Application: Use cases
  - Infrastructure: Technical details
  - Interfaces: Contracts

- **Open/Closed**: Extensão via interfaces e implementações
  - Adicionar novos schedulers sem modificar StudyService
  - Adicionar novos repositories sem modificar domain
  - Adicionar novos handlers sem modificar services

- **Liskov Substitution**: Implementações são intercambiáveis
  - Qualquer CardRepository pode substituir outro
  - Qualquer SchedulerService pode substituir outro
  - Testes usam in-memory, produção usa PostgreSQL

- **Interface Segregation**: Interfaces focadas por use case
  - CardRepository específico para cards
  - DeckRepository específico para decks
  - Não há "fat interfaces" genéricas

- **Dependency Inversion**: Core depende de abstrações
  - Domain define interfaces (ports)
  - Infrastructure implementa interfaces (adapters)
  - Application depende de interfaces, não concretions

**→ Para exemplos detalhados, ver [Seção 5: Princípios SOLID Aplicados](#5-princípios-solid-aplicados)**

## 2. Technology Stack

### 2.1 Backend Stack

- **Linguagem**: Go 1.21+
- **Framework HTTP**: Gorilla Mux ou Chi Router
- **Database**: PostgreSQL 15+ (banco relacional de produção)
- **Caching**: Redis 7+ (sessões, refresh tokens, dados temporários)
- **ORM/Database Driver**: `database/sql` + `lib/pq` (PostgreSQL driver)
- **Authentication**: JWT (access tokens) + bcrypt (password hashing)
- **Testing**: `testing` package + `testify` (assertions, mocks)
- **Containerization**: Docker & Docker Compose
- **Migrations**: golang-migrate
- **Logging**: `log/slog` (structured logging)
- **Configuration**: Environment variables + struct validation

### 2.2 Database & Caching

- **PostgreSQL** com connection pooling
  - Pool size configurável (default: 25 conexões)
  - Max idle connections: 5
  - Connection lifetime: 5 minutos
  - Idle timeout: 10 minutos

- **Redis** para cache de alta performance
  - Cache de entidades frequentes (cards, decks)
  - Session storage (tokens, sessões)
  - Rate limiting
  - Job queue (background jobs)

- **Migrations**: golang-migrate
  - Versionamento de schema
  - Rollback support
  - CI/CD integration

- **Índices**: Criados em colunas frequentemente consultadas
  - `cards.due`, `cards.deck_id`, `cards.state`
  - `decks.user_id`, `decks.parent_id`
  - `notes.user_id`, `notes.guid`

### 2.3 Code Standards

- **Todo código em inglês**: comentários, nomes de variáveis, mensagens de erro
- **Convenções Go**: Seguir `gofmt`, `golint`, `go vet`
- **Nomes descritivos**: Variáveis e funções devem revelar intenção
- **Código auto-documentado**: Minimizar necessidade de comentários
- **Documentação**: Comentários para APIs públicas (godoc)
- **Error handling**: Sempre tratar erros explicitamente
- **Type safety**: Usar tipos específicos, evitar `interface{}` quando possível

**Exemplo**:

```go
// ✅ GOOD: Nome descritivo, código claro
func (s *CardService) GetDueCardsForDeck(ctx context.Context, deckID int64) ([]*entities.Card, error) {
    // ...
}

// ❌ BAD: Nome genérico, código não claro
func (s *CardService) Get(ctx context.Context, id int64) (interface{}, error) {
    // ...
}
```

## 3. Estrutura de Diretórios

### 3.1 Arquitetura Hexagonal - Estrutura do Projeto

Este projeto segue a **Arquitetura Hexagonal (Ports & Adapters)** conforme definido no guia de princípios arquiteturais, utilizando a estrutura exata do padrão colabora-2.0 adaptada para Go.

**Estrutura Base**:
- **`core/`**: Camada de domínio e lógica de negócio (Hexagon Center)
- **`infra/`**: Adaptadores secundários (Database, Redis, Storage, etc.)
- **`app/`**: Adaptadores primários (HTTP API, WebSocket, etc.)
- **`config/`**: Configuração da aplicação

### 3.2 Organização do Projeto (Estrutura Completa)

```
backend/
├── cmd/
│   └── api/
│       └── main.go                    # Entry point da aplicação
│
├── core/                              # 🎯 CORE LAYER (Hexagon Center)
│   ├── domain/                        # Domain Layer (Pure Business Logic)
│   │   ├── entities/                  # Entidades de domínio
│   │   │   ├── user.go
│   │   │   ├── deck.go
│   │   │   ├── note.go
│   │   │   ├── card.go
│   │   │   └── review.go
│   │   ├── valueobjects/              # Value Objects
│   │   │   ├── email.go
│   │   │   ├── password.go
│   │   │   ├── guid.go
│   │   │   ├── card_state.go
│   │   │   └── deck_options.go
│   │   ├── services/                  # Domain Services
│   │   │   ├── scheduler.go           # Algoritmos SM-2 e FSRS
│   │   │   ├── card_generator.go      # Geração de cards
│   │   │   ├── template_renderer.go   # Renderização de templates
│   │   │   └── search_parser.go       # Parser de busca Anki
│   │   └── events/                    # Domain Events
│   │       ├── card_reviewed.go
│   │       ├── note_created.go
│   │       └── deck_updated.go
│   │
│   ├── interfaces/                    # 🔵 PORTS (Interfaces)
│   │   ├── primary/                   # 🔵 PRIMARY PORTS (Service Interfaces)
│   │   │   ├── auth_service.go       # IAuthService interface
│   │   │   ├── deck_service.go       # IDeckService interface
│   │   │   ├── note_service.go       # INoteService interface
│   │   │   ├── study_service.go      # IStudyService interface
│   │   │   ├── sync_service.go       # ISyncService interface
│   │   │   └── stats_service.go      # IStatsService interface
│   │   └── secondary/                 # 🟢 SECONDARY PORTS (Repository Interfaces)
│   │       ├── user_repository.go     # IUserRepository interface
│   │       ├── deck_repository.go     # IDeckRepository interface
│   │       ├── note_repository.go    # INoteRepository interface
│   │       ├── card_repository.go    # ICardRepository interface
│   │       └── review_repository.go  # IReviewRepository interface
│   │
│   └── services/                      # Application Services (implements primary ports)
│       ├── auth/
│       │   └── auth_service.go       # AuthService implements IAuthService
│       ├── deck/
│       │   └── deck_service.go       # DeckService implements IDeckService
│       ├── note/
│       │   └── note_service.go      # NoteService implements INoteService
│       ├── study/
│       │   └── study_service.go     # StudyService implements IStudyService
│       ├── sync/
│       │   └── sync_service.go       # SyncService implements ISyncService
│       ├── stats/
│       │   └── stats_service.go     # StatsService implements IStatsService
│       └── filters/                  # Filter pattern
│           ├── base_filter.go
│           ├── deck_filter.go
│           └── card_filter.go
│
├── infra/                             # 🔌 INFRASTRUCTURE LAYER (Secondary Adapters)
│   ├── database/                      # Database Adapter
│   │   ├── models/                    # 🔵 Database Models (DB Schema)
│   │   │   ├── user_model.go
│   │   │   ├── deck_model.go
│   │   │   ├── note_model.go
│   │   │   ├── card_model.go
│   │   │   └── review_model.go
│   │   ├── mappers/                   # 🔵 Database Mappers (DB ↔ Domain)
│   │   │   ├── user_mapper.go
│   │   │   ├── deck_mapper.go
│   │   │   ├── note_mapper.go
│   │   │   ├── card_mapper.go
│   │   │   └── review_mapper.go
│   │   └── repositories/              # Repository Implementations
│   │       ├── user_repository.go     # PostgresUserRepository implements IUserRepository
│   │       ├── deck_repository.go     # PostgresDeckRepository implements IDeckRepository
│   │       ├── note_repository.go     # PostgresNoteRepository implements INoteRepository
│   │       ├── card_repository.go      # PostgresCardRepository implements ICardRepository
│   │       └── review_repository.go   # PostgresReviewRepository implements IReviewRepository
│   │
│   ├── redis/                         # Redis Cache Adapter
│   │   └── redis_cache.go
│   │
│   ├── storage/                       # Storage Adapter
│   │   ├── local_storage.go
│   │   └── s3_storage.go
│   │
│   ├── messaging/                     # Event bus/pub-sub Adapter
│   │   └── event_bus.go
│   │
│   ├── external/                      # External Services Adapter
│   │   ├── email_service.go
│   │   └── media_processor.go
│   │
│   └── jobs/                          # Background Jobs Adapter
│       ├── job_queue.go
│       └── worker_pool.go
│
├── app/                               # 🖥️ APPLICATION LAYER (Primary Adapters)
│   └── api/                           # HTTP API Adapter
│       ├── routes/                    # HTTP Routes
│       │   ├── auth_routes.go
│       │   ├── deck_routes.go
│       │   ├── note_routes.go
│       │   ├── study_routes.go
│       │   └── sync_routes.go
│       ├── dtos/                      # 🔵 HTTP DTOs (Request/Response)
│       │   ├── request/               # Request DTOs
│       │   │   ├── auth_request.go
│       │   │   ├── deck_request.go
│       │   │   ├── note_request.go
│       │   │   └── study_request.go
│       │   └── response/              # Response DTOs
│       │       ├── auth_response.go
│       │       ├── deck_response.go
│       │       ├── note_response.go
│       │       ├── study_response.go
│       │       └── paginated_response.go
│       ├── mappers/                   # 🔵 HTTP Mappers (DTO ↔ Domain)
│       │   ├── auth_mapper.go
│       │   ├── deck_mapper.go
│       │   ├── note_mapper.go
│       │   └── card_mapper.go
│       ├── middlewares/               # HTTP Middleware
│       │   ├── auth_middleware.go
│       │   ├── logging_middleware.go
│       │   ├── error_middleware.go
│       │   ├── rate_limiting_middleware.go
│       │   └── request_id_middleware.go
│       ├── utils/                     # HTTP Utilities
│       │   ├── pagination.go
│       │   └── validators.go
│       └── router.go                 # Router setup
│
├── config/                            # Configuration
│   └── config.go
│
├── pkg/                               # 📦 Pacotes públicos reutilizáveis
│   ├── errors/                        # Erros customizados
│   ├── logger/                        # Logger estruturado
│   ├── validator/                     # Validators genéricos
│   ├── pagination/                    # Paginação
│   ├── filters/                       # Filter pattern (base)
│   └── metrics/                       # Métricas (Prometheus)
│
├── migrations/                         # Database migrations (golang-migrate)
│   ├── 000001_initial_schema.up.sql
│   ├── 000001_initial_schema.down.sql
│   ├── 000002_add_deck_options.up.sql
│   └── 000002_add_deck_options.down.sql
│
├── scripts/                            # Scripts utilitários (todos .sh aqui)
│   ├── dev.sh                         # Iniciar ambiente de desenvolvimento
│   ├── test.sh                        # Rodar testes
│   ├── migrate.sh                     # Executar migrations
│   ├── build.sh                       # Build da aplicação
│   └── deploy.sh                      # Deploy em produção
│
├── tests/                              # Testes
│   ├── unit/                          # Testes unitários
│   ├── integration/                   # Testes de integração
│   └── e2e/                           # Testes end-to-end
│
├── docs/                              # Documentação (todos .md aqui)
│   ├── Arquitetura Backend - Sistema Anki.md
│   ├── API_ENDPOINTS.md               # Documentação da API
│   ├── DEPLOYMENT.md                  # Guia de deployment
│   ├── TESTING.md                     # Guia de testes
│   └── TROUBLESHOOTING.md             # Troubleshooting
│
├── go.mod
├── go.sum
├── .env.example                       # Exemplo de variáveis de ambiente
├── .gitignore                         # Previne .md e .sh na raiz
├── Dockerfile
├── docker-compose.yml
└── README.md                          # ✅ Exception - fica na raiz
```

### 3.3 Responsabilidades das Camadas

#### Core Layer (Hexagon Center)

**Estrutura**: `core/`

- **`core/domain/`**: Pure business logic, entities, value objects, domain services, events
  - Sem dependências de frameworks
  - Regras de negócio e validações
  - Modelos de domínio (entidades)

- **`core/interfaces/primary/`**: Primary Ports (Service Interfaces)
  - Interfaces para adapters primários (API, CLI, etc.)
  - Define contratos de serviços (IDeckService, IAuthService, etc.)
  - Implementadas por Application Services

- **`core/interfaces/secondary/`**: Secondary Ports (Repository Interfaces)
  - Interfaces para adapters secundários (Database, External APIs, etc.)
  - Define contratos de repositórios (IDeckRepository, ICardRepository, etc.)
  - Implementadas por Infrastructure Adapters

- **`core/services/`**: Application Services (Use Cases)
  - Orquestra operações de negócio
  - Implementa primary ports (interfaces)
  - Depende de repository interfaces (secondary ports)
  - Contém lógica de negócio apenas

- **`core/services/filters/`**: Filter Pattern
  - Filtros, paginação, ordenação
  - Reutilizável entre diferentes entidades

#### Infrastructure Layer (Secondary Adapters)

**Estrutura**: `infra/`

- **`infra/database/`**: Database Adapter
  - **`models/`**: Database models (DB Schema)
  - **`mappers/`**: Database Mappers (DB ↔ Domain)
  - **`repositories/`**: Repository Implementations (implementa secondary ports)

- **`infra/redis/`**: Redis Cache Adapter
- **`infra/storage/`**: Storage Adapter (Local, S3)
- **`infra/messaging/`**: Event bus/pub-sub Adapter
- **`infra/external/`**: External Services Adapter (Email, Media Processing)
- **`infra/jobs/`**: Background Jobs Adapter

#### Application Layer (Primary Adapters)

**Estrutura**: `app/`

- **`app/api/`**: HTTP API Adapter
  - **`routes/`**: HTTP Routes
  - **`dtos/`**: HTTP DTOs (Request/Response)
  - **`mappers/`**: HTTP Mappers (DTO ↔ Domain)
  - **`middlewares/`**: HTTP Middleware
  - **`utils/`**: HTTP Utilities
  - **`router.go`**: Router setup

### 3.4 Justificativa da Estrutura

#### Por que `core/`, `infra/`, `app/` em vez de `internal/`?

Esta estrutura segue exatamente o padrão do colabora-2.0, que implementa Hexagonal Architecture de forma explícita:

**Benefícios**:
- ✅ **Separação explícita de Ports**: `core/interfaces/primary/` e `core/interfaces/secondary/` deixam claro quais são os ports
- ✅ **Consistência entre projetos**: Mesma estrutura do backend Python (colabora-2.0)
- ✅ **Clareza arquitetural**: `core/`, `infra/`, `app/` deixam explícito o papel de cada camada
- ✅ **Facilita comunicação**: Equipes frontend e backend falam a mesma "linguagem" arquitetural
- ✅ **Hexagonal Architecture explícita**: Estrutura deixa claro que é Ports & Adapters

#### Onde colocar DTOs e Mappers?

**Cada camada tem seus próprios DTOs e Mappers** porque cada uma tem responsabilidades diferentes:

**1. HTTP Layer (Primary Adapter)**:
```
app/api/
├── dtos/
│   ├── request/          # Request DTOs (HTTP → Domain)
│   │   ├── deck_request.go
│   │   └── note_request.go
│   └── response/         # Response DTOs (Domain → HTTP)
│       ├── deck_response.go
│       └── note_response.go
└── mappers/              # HTTP Mappers (DTO ↔ Domain)
    ├── deck_mapper.go
    └── note_mapper.go
```

**Exemplo de código**:

```go
// app/api/dtos/request/deck_request.go
package request

type CreateDeckRequest struct {
    Name        string `json:"name" validate:"required,min=1,max=100"`
    Description string `json:"description" validate:"max=500"`
    ParentID    *int64 `json:"parent_id,omitempty"`
}

type UpdateDeckRequest struct {
    Name        *string `json:"name,omitempty" validate:"omitempty,min=1,max=100"`
    Description *string `json:"description,omitempty" validate:"omitempty,max=500"`
}

// app/api/dtos/response/deck_response.go
package response

type DeckResponse struct {
    ID          int64     `json:"id"`
    Name        string    `json:"name"`
    Description string    `json:"description"`
    ParentID    *int64    `json:"parent_id,omitempty"`
    CreatedAt   time.Time `json:"created_at"`
    UpdatedAt   time.Time `json:"updated_at"`
}

type PaginatedDeckResponse struct {
    Items      []DeckResponse `json:"items"`
    Page       int            `json:"page"`
    PageSize   int            `json:"page_size"`
    Total      int64          `json:"total"`
    TotalPages int            `json:"total_pages"`
}

// app/api/mappers/deck_mapper.go
package mappers

import (
    "github.com/anki/core/domain/entities"
    "github.com/anki/app/api/dtos/request"
    "github.com/anki/app/api/dtos/response"
)

type DeckMapper struct{}

func (m *DeckMapper) ToDomain(req *request.CreateDeckRequest) *entities.Deck {
    return &entities.Deck{
        Name:        req.Name,
        Description: req.Description,
        ParentID:    req.ParentID,
    }
}

func (m *DeckMapper) ToResponse(deck *entities.Deck) *response.DeckResponse {
    return &response.DeckResponse{
        ID:          deck.ID,
        Name:        deck.Name,
        Description: deck.Description,
        ParentID:    deck.ParentID,
        CreatedAt:   deck.CreatedAt,
        UpdatedAt:   deck.UpdatedAt,
    }
}

func (m *DeckMapper) ToResponseList(decks []*entities.Deck) []response.DeckResponse {
    responses := make([]response.DeckResponse, len(decks))
    for i, deck := range decks {
        responses[i] = *m.ToResponse(deck)
    }
    return responses
}
```

**2. Infrastructure Layer (Secondary Adapter - Repositories)**:
```
infra/database/
├── repositories/         # Repository Implementations
│   ├── user_repository.go
│   ├── deck_repository.go
│   ├── note_repository.go
│   ├── card_repository.go
│   └── review_repository.go
├── models/              # 🔵 Database Models (DB Schema)
│   ├── user_model.go
│   ├── deck_model.go
│   ├── note_model.go
│   ├── card_model.go
│   └── review_model.go
└── mappers/             # 🔵 Database Mappers (DB ↔ Domain)
    ├── user_mapper.go
    ├── deck_mapper.go
    ├── note_mapper.go
    ├── card_mapper.go
    └── review_mapper.go
```

**Exemplo de código completo**:

```go
// infra/database/models/deck_model.go
package models

import "time"

// DeckModel represents the database schema for decks table
type DeckModel struct {
    ID          int64     `db:"id"`
    UserID      int64     `db:"user_id"`
    Name        string    `db:"name"`
    Description string    `db:"description"`
    ParentID    *int64    `db:"parent_id"`
    CreatedAt   time.Time `db:"created_at"`
    UpdatedAt   time.Time `db:"updated_at"`
}

// TableName returns the table name
func (DeckModel) TableName() string {
    return "decks"
}

// infra/database/mappers/deck_mapper.go
package mappers

import (
    "github.com/anki/core/domain/entities"
    "github.com/anki/infra/database/models"
)

// DeckMapper converts between database models and domain entities
type DeckMapper struct{}

// NewDeckMapper creates a new deck mapper
func NewDeckMapper() *DeckMapper {
    return &DeckMapper{}
}

// ToDomain converts database model to domain entity
func (m *DeckMapper) ToDomain(db *models.DeckModel) *entities.Deck {
    if db == nil {
        return nil
    }
    
    return &entities.Deck{
        ID:          db.ID,
        UserID:      db.UserID,
        Name:        db.Name,
        Description: db.Description,
        ParentID:    db.ParentID,
        CreatedAt:   db.CreatedAt,
        UpdatedAt:   db.UpdatedAt,
    }
}

// ToDomainList converts a slice of database models to domain entities
func (m *DeckMapper) ToDomainList(dbModels []*models.DeckModel) []*entities.Deck {
    if len(dbModels) == 0 {
        return nil
    }
    
    domains := make([]*entities.Deck, len(dbModels))
    for i, db := range dbModels {
        domains[i] = m.ToDomain(db)
    }
    return domains
}

// FromDomain converts domain entity to database model
func (m *DeckMapper) FromDomain(deck *entities.Deck) *models.DeckModel {
    if deck == nil {
        return nil
    }
    
    return &models.DeckModel{
        ID:          deck.ID,
        UserID:      deck.UserID,
        Name:        deck.Name,
        Description: deck.Description,
        ParentID:    deck.ParentID,
        CreatedAt:   deck.CreatedAt,
        UpdatedAt:   deck.UpdatedAt,
    }
}

// infra/database/repositories/deck_repository.go
package repositories

import (
    "context"
    "database/sql"
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/interfaces/secondary"
    "github.com/anki/infra/database/models"
    "github.com/anki/infra/database/mappers"
)

type PostgresDeckRepository struct {
    db     *sql.DB
    mapper *mappers.DeckMapper
}

// NewPostgresDeckRepository creates a new PostgreSQL deck repository
func NewPostgresDeckRepository(db *sql.DB) secondary.IDeckRepository {
    return &PostgresDeckRepository{
        db:     db,
        mapper: mappers.NewDeckMapper(),
    }
}

// FindByID implements secondary.IDeckRepository
func (r *PostgresDeckRepository) FindByID(ctx context.Context, id int64) (*entities.Deck, error) {
    var dbModel models.DeckModel
    query := `SELECT id, user_id, name, description, parent_id, created_at, updated_at 
              FROM decks WHERE id = $1`
    
    err := r.db.QueryRowContext(ctx, query, id).Scan(
        &dbModel.ID,
        &dbModel.UserID,
        &dbModel.Name,
        &dbModel.Description,
        &dbModel.ParentID,
        &dbModel.CreatedAt,
        &dbModel.UpdatedAt,
    )
    if err != nil {
        if err == sql.ErrNoRows {
            return nil, secondary.ErrDeckNotFound
        }
        return nil, err
    }
    
    // Convert DB model to Domain entity using mapper
    return r.mapper.ToDomain(&dbModel), nil
}

// Save implements secondary.IDeckRepository
func (r *PostgresDeckRepository) Save(ctx context.Context, deck *entities.Deck) error {
    // Convert Domain entity to DB model using mapper
    dbModel := r.mapper.FromDomain(deck)
    
    if deck.ID == 0 {
        // Insert
        query := `INSERT INTO decks (user_id, name, description, parent_id, created_at, updated_at)
                  VALUES ($1, $2, $3, $4, $5, $6) RETURNING id`
        err := r.db.QueryRowContext(ctx, query,
            dbModel.UserID,
            dbModel.Name,
            dbModel.Description,
            dbModel.ParentID,
            dbModel.CreatedAt,
            dbModel.UpdatedAt,
        ).Scan(&dbModel.ID)
        if err != nil {
            return err
        }
        deck.ID = dbModel.ID
    } else {
        // Update
        query := `UPDATE decks SET name = $1, description = $2, parent_id = $3, updated_at = $4
                  WHERE id = $5`
        _, err := r.db.ExecContext(ctx, query,
            dbModel.Name,
            dbModel.Description,
            dbModel.ParentID,
            dbModel.UpdatedAt,
            dbModel.ID,
        )
        if err != nil {
            return err
        }
    }
    
    return nil
}
```

**Por que não em `core/services/dto/` e `core/services/mappers/`?**

- ❌ **Application services trabalham com Domain diretamente** - não precisam de DTOs
- ✅ **DTOs são específicos de cada adapter** - HTTP tem seus DTOs, WebSocket teria outros
- ✅ **Mappers devem estar onde são usados** - HTTP mappers em `app/api/mappers/`, DB mappers em `infra/database/mappers/`
- ✅ **Separation of Concerns** - Cada camada cuida de suas próprias conversões

**Fluxo de conversão**:

```
HTTP Request DTO (app/api/dtos/request/)
    ↓ (HTTP Mapper em app/api/mappers/)
Domain Entity (core/domain/entities/)
    ↓ (Application Service em core/services/ usa Domain)
Domain Entity
    ↓ (DB Mapper em infra/database/mappers/)
Database Model (infra/database/models/)
    ↓ (Repository em infra/database/repositories/ salva)
Database
```

#### Onde declarar Primary Ports (Service Interfaces)?

**Os Primary Ports ficam em `core/interfaces/primary/`**:

```
core/
├── interfaces/
│   ├── primary/            # 🔵 PRIMARY PORTS (Service Interfaces)
│   │   ├── auth_service.go    # type IAuthService interface { ... }
│   │   ├── deck_service.go    # type IDeckService interface { ... }
│   │   └── study_service.go   # type IStudyService interface { ... }
│   └── secondary/          # 🟢 SECONDARY PORTS (Repository Interfaces)
│       ├── user_repository.go
│       ├── deck_repository.go
│       └── card_repository.go
└── services/              # Implementações (implementam as interfaces)
    ├── auth/
    │   └── auth_service.go    # AuthService implements IAuthService
    ├── deck/
    │   └── deck_service.go    # DeckService implements IDeckService
    └── study/
        └── study_service.go   # StudyService implements IStudyService
```

**Exemplo de código**:

```go
// core/interfaces/primary/deck_service.go
package primary

import (
    "context"
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/services/filters"
)

// IDeckService is the primary port for deck operations
type IDeckService interface {
    CreateDeck(ctx context.Context, deck *entities.Deck) (*entities.Deck, error)
    GetDeck(ctx context.Context, deckID int64) (*entities.Deck, error)
    ListDecks(ctx context.Context, filter *filters.DeckFilter) ([]*entities.Deck, error)
    UpdateDeck(ctx context.Context, deckID int64, deck *entities.Deck) (*entities.Deck, error)
    DeleteDeck(ctx context.Context, deckID int64) error
}
```

```go
// core/services/deck/deck_service.go
package deck

import (
    "context"
    "github.com/anki/core/interfaces/primary"
    "github.com/anki/core/interfaces/secondary"
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/services/filters"
)

// DeckService implements primary.IDeckService (primary port)
type DeckService struct {
    deckRepo secondary.IDeckRepository // Secondary port (interface)
}

// NewDeckService creates a new deck service
func NewDeckService(deckRepo secondary.IDeckRepository) primary.IDeckService {
    return &DeckService{deckRepo: deckRepo}
}

// CreateDeck implements primary.IDeckService
func (s *DeckService) CreateDeck(ctx context.Context, deck *entities.Deck) (*entities.Deck, error) {
    // Business logic
    deck.Validate()
    // Save using repository
    return s.deckRepo.Save(ctx, deck)
}
```

**Por que `core/interfaces/primary/` e `core/interfaces/secondary/`?**

- ✅ **Separação explícita**: Primary e Secondary ports claramente separados
- ✅ **Consistência**: Segue exatamente a estrutura do colabora-2.0
- ✅ **Hexagonal Architecture explícita**: Estrutura deixa claro que são Ports
- ✅ **Organização lógica**: Todos os ports (interfaces) em um lugar, implementações em outro


#### Por que `app/api/` para HTTP Adapters?

**Estrutura do colabora-2.0**:
```
app/
└── api/                  # HTTP API Adapter (Primary Adapter)
    ├── routes/
    ├── dtos/
    ├── mappers/
    ├── middlewares/
    └── utils/
```

**Por que esta estrutura?**
- ✅ **Consistência**: Segue exatamente a estrutura do colabora-2.0
- ✅ **Clareza**: `app/` deixa claro que são adapters primários (Primary Adapters)
- ✅ **Organização**: Agrupa todos os componentes HTTP em um lugar
- ✅ **Hexagonal Architecture**: `app/` vs `infra/` deixa explícito Primary vs Secondary adapters

### 3.5 Mapeamento Hexagonal Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    APP LAYER                             │
│              (Primary Adapters - Driving)                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  app/api/    │  │  app/ws/     │  │  app/cli/     │  │
│  │  (HTTP API)  │  │  (WebSocket) │  │  (CLI future) │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│         │                  │                  │          │
│         └──────────────────┼──────────────────┘          │
│                            ↓                            │
│              Uses Primary Ports (core/interfaces/primary/)│
└───────────────────────┬─────────────────────────────────┘
                        │
                        ↓
┌─────────────────────────────────────────────────────────┐
│                    CORE LAYER                            │
│              (Hexagon Center)                            │
│  ┌──────────────────────────────────────────────────┐   │
│  │  🔵 PRIMARY PORTS (core/interfaces/primary/)     │   │
│  │  IAuthService, IDeckService, IStudyService       │   │
│  └──────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Implementations (core/services/)                │   │
│  │  AuthService, DeckService, StudyService          │   │
│  └──────────────────────────────────────────────────┘   │
│                            │                            │
│                            ↓                            │
│              Uses Secondary Ports (core/interfaces/secondary/)│
│  ┌──────────────────────────────────────────────────┐   │
│  │  🟢 SECONDARY PORTS (core/interfaces/secondary/) │   │
│  │  IUserRepository, IDeckRepository, etc.          │   │
│  └──────────────────────────────────────────────────┘   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │ Entities │  │ Services │  │  Events  │             │
│  │(domain/) │  │(domain/) │  │(domain/) │             │
│  └──────────┘  └──────────┘  └──────────┘             │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ↑
┌─────────────────────────────────────────────────────────┐
│               INFRA LAYER                                │
│          (Secondary Adapters - Driven)                   │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Implements Secondary Ports                      │   │
│  │  (infra/database/repositories/)                  │   │
│  │  PostgresUserRepository, PostgresDeckRepository │   │
│  └──────────────────────────────────────────────────┘   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │PostgreSQL│  │  Redis   │  │   S3     │             │
│  │(infra/   │  │(infra/   │  │(infra/   │             │
│  │database/)│  │redis/)   │  │storage/) │             │
│  └──────────┘  └──────────┘  └──────────┘             │
└─────────────────────────────────────────────────────────┘
```

### 3.6 Resumo: Onde Declarar Ports, Adapters, DTOs e Mappers

| Tipo | Localização | Exemplo |
|------|-------------|---------|
| **Primary Ports** | `application/interfaces/` | `IDeckService`, `IAuthService` |
| **Primary Adapters** | `interfaces/http/`, `interfaces/websocket/` | HTTP handlers, WebSocket handlers |
| **HTTP DTOs** | `interfaces/http/dto/request/`, `interfaces/http/dto/response/` | `CreateDeckRequest`, `DeckResponse` |
| **HTTP Mappers** | `interfaces/http/mappers/` | `DeckMapper` (DTO ↔ Domain) |
| **Secondary Ports** | `core/interfaces/secondary/` | `IDeckRepository`, `ICardRepository` |
| **Secondary Adapters** | `infrastructure/persistence/` | `PostgresDeckRepository`, `RedisCache` |
| **Repository Implementations** | `infrastructure/persistence/postgres/repositories/` | `PostgresDeckRepository` |
| **Database Models** | `infrastructure/persistence/postgres/models/` | `DeckModel`, `CardModel` |
| **Database Mappers** | `infrastructure/persistence/postgres/mappers/` | `DeckMapper` (DB ↔ Domain) |

**Fluxo de Dependências**:
```
HTTP Route (app/api/routes/) - Primary Adapter
    ↓ usa
IDeckService (core/interfaces/primary/) - Primary Port
    ↓ implementado por
DeckService (core/services/deck/) - Application Service
    ↓ usa
IDeckRepository (core/interfaces/secondary/) - Secondary Port
    ↓ implementado por
PostgresDeckRepository (infra/database/repositories/) - Secondary Adapter
    ↓ usa
Database (PostgreSQL)
```

### 3.6 Convenções de Organização

### 3.2 Convenções de Organização

#### Documentação (`docs/` folder)
**Toda documentação `.md` deve estar na pasta `docs/`**:
- ✅ `docs/Arquitetura Backend - Sistema Anki.md`
- ✅ `docs/API_ENDPOINTS.md`
- ✅ `docs/DEPLOYMENT.md`
- ❌ `arquitetura.md` (na raiz) - Localização incorreta

**Exceção**: `README.md` fica na raiz para visibilidade no GitHub.

#### Scripts (`scripts/` folder)
**Todos os scripts `.sh` devem estar na pasta `scripts/`**:
- ✅ `scripts/dev.sh`
- ✅ `scripts/test.sh`
- ✅ `scripts/migrate.sh`
- ❌ `run.sh` (na raiz) - Localização incorreta

#### Testes (`tests/` folder)
**Testes organizados por tipo**:
- ✅ `tests/unit/` - Testes unitários
- ✅ `tests/integration/` - Testes de integração
- ✅ `tests/e2e/` - Testes end-to-end

### 3.3 Responsabilidades das Camadas

#### Domain Layer (Core)
- **Pure business logic** (lógica de negócio pura)
- **No framework dependencies** (sem dependências de frameworks)
- **Business rules and validations** (regras de negócio e validações)
- **Domain models (entities)** (modelos de domínio - entidades)
- **Value Objects** (objetos de valor)
- **Domain Services** (serviços de domínio)
- **Domain Events** (eventos de domínio)
- **Repository Interfaces (Ports)** (interfaces de repositório - ports)

**Exemplo**:
```go
// Domain não conhece HTTP, SQL, Redis
type Card struct {
    ID    int64
    Due   int64
    State CardState
}

func (c *Card) IsDue(now int64) bool {
    // Pure business logic
    return c.Due <= now && !c.Suspended && !c.Buried
}
```

#### Application Layer (Use Cases)
- **Orchestrates business operations** (orquestra operações de negócio)
- **Implements primary ports (interfaces)** (implementa ports primários)
- **Depends on repository interfaces** (depende de interfaces de repositório)
- **Contains business logic only** (contém apenas lógica de negócio)
- **DTOs and Mappers** (DTOs e mappers)

**Exemplo**:
```go
// Application orquestra use cases
type StudyService struct {
    cardRepo secondary.ICardRepository // Interface, não implementação
}

func (s *StudyService) ReviewCard(ctx context.Context, cardID int64, rating int) error {
    // Orquestra: busca card, calcula intervalo, salva
}
```

#### Infrastructure Layer (Technical Details)
- **Implements secondary ports (interfaces)** (implementa ports secundários)
- **Database operations (CRUD)** (operações de banco de dados)
- **Filters, pagination, sorting** (filtros, paginação, ordenação)
- **Uses mappers for conversions** (usa mappers para conversões)
- **External services** (serviços externos)
- **Cache implementations** (implementações de cache)

**Exemplo**:
```go
// Infrastructure implementa interfaces do domain
type PostgresCardRepository struct {
    db *sql.DB // Detalhe técnico
}

func (r *PostgresCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // SQL específico do PostgreSQL
}
```

#### Interfaces Layer (Adapters)
- **HTTP endpoints** (endpoints HTTP)
- **Request/Response DTOs** (DTOs de requisição/resposta)
- **Authentication & authorization** (autenticação e autorização)
- **Input validation** (validação de entrada)
- **Maps DTOs to domain models** (mapeia DTOs para modelos de domínio)
- **WebSocket handlers** (handlers WebSocket)

**Exemplo**:
```go
// Interfaces traduz HTTP para domain
func (h *CardHandler) GetCard(w http.ResponseWriter, r *http.Request) {
    // Parse HTTP request
    // Chama service
    // Converte domain para DTO
    // Retorna HTTP response
}
```

## 3. Camadas Detalhadas

### 3.1 Domain Layer (Domínio)

**Responsabilidade**: Contém a lógica de negócio pura, sem dependências externas.

#### 3.1.1 Entities (Entidades)

Entidades são objetos com identidade única e ciclo de vida.

**Exemplo: `core/domain/entities/card.go`**

```go
package entities

import (
    "time"
    "github.com/anki/core/domain/valueobjects"
)

// Card representa um card de estudo
type Card struct {
    ID          int64
    NoteID      int64
    CardTypeID  int
    DeckID      int64
    HomeDeckID  *int64  // Para filtered decks
    Due         int64   // Timestamp em ms ou posição para new cards
    Interval    int     // Dias (ou segundos negativos para learning)
    Ease        int     // Ease factor em permille (2500 = 2.5x)
    Lapses      int
    Reps        int
    State       valueobjects.CardState
    Position    int     // Posição na fila de novos cards
    Flag        int     // 0-7
    Suspended   bool
    Buried      bool
    
    // Campos FSRS
    Stability   *float64
    Difficulty  *float64
    LastReviewAt *time.Time
    
    CreatedAt   time.Time
    UpdatedAt   time.Time
}

// IsDue verifica se o card está due para estudo
func (c *Card) IsDue(now int64) bool {
    if c.Suspended || c.Buried {
        return false
    }
    
    switch c.State {
    case valueobjects.CardStateNew:
        return true // New cards sempre estão disponíveis
    case valueobjects.CardStateLearn, valueobjects.CardStateRelearn:
        return c.Due <= now
    case valueobjects.CardStateReview:
        return c.Due <= now
    default:
        return false
    }
}

// MarkAsReviewed marca o card como revisado
func (c *Card) MarkAsReviewed(rating int, newInterval int, newEase int) {
    c.Reps++
    c.Interval = newInterval
    c.Ease = newEase
    c.UpdatedAt = time.Now()
    
    if rating == 1 { // Again
        c.Lapses++
        if c.State == valueobjects.CardStateReview {
            c.State = valueobjects.CardStateRelearn
        }
    }
}
```

**Exemplo: `core/domain/entities/deck.go`**

```go
package entities

import (
    "time"
    "github.com/anki/core/domain/valueobjects"
)

// Deck representa um deck (baralho) de cards
type Deck struct {
    ID          int64
    UserID      int64
    Name        string
    ParentID    *int64
    Options     *valueobjects.DeckOptions
    CreatedAt   time.Time
    UpdatedAt   time.Time
    DeletedAt   *time.Time
}

// IsRoot verifica se o deck é um deck raiz (sem pai)
func (d *Deck) IsRoot() bool {
    return d.ParentID == nil
}

// HasChildren verifica se o deck tem subdecks
func (d *Deck) HasChildren() bool {
    // Implementação verificaria se há subdecks
    return false
}
```

**Exemplo: `core/domain/entities/note.go`**

```go
package entities

import (
    "time"
    "github.com/anki/core/domain/valueobjects"
)

// Note representa uma nota que gera cards
type Note struct {
    ID          int64
    UserID      int64
    GUID        valueobjects.GUID
    NoteTypeID  int64
    Fields      map[string]string
    Tags        []string
    Marked      bool
    CreatedAt   time.Time
    UpdatedAt   time.Time
    DeletedAt   *time.Time
}

// GetFirstField retorna o primeiro campo (usado para duplicatas)
func (n *Note) GetFirstField() string {
    // Retorna o primeiro campo do map (ordem não garantida em Go)
    // Em produção, usar ordem definida no NoteType
    for _, v := range n.Fields {
        return v
    }
    return ""
}
```

**Exemplo: `core/domain/entities/review.go`**

```go
package entities

import (
    "time"
    "github.com/anki/core/domain/valueobjects"
)

// Review representa uma revisão de um card
type Review struct {
    ID          int64
    CardID      int64
    Rating      int     // 1=Again, 2=Hard, 3=Good, 4=Easy
    Interval    int     // Novo intervalo após revisão
    Ease        int     // Novo ease factor após revisão
    TimeMs      int     // Tempo gasto na revisão (milliseconds)
    Type        valueobjects.ReviewType
    CreatedAt   time.Time
}
```

**Exemplo: `core/domain/entities/user.go`**

```go
package entities

import (
    "time"
    "github.com/anki/core/domain/valueobjects"
)

// User representa um usuário do sistema
type User struct {
    ID            int64
    Email         valueobjects.Email
    PasswordHash  string
    EmailVerified bool
    CreatedAt     time.Time
    UpdatedAt     time.Time
    LastLoginAt   *time.Time
    DeletedAt     *time.Time
}

// IsActive verifica se o usuário está ativo
func (u *User) IsActive() bool {
    return u.DeletedAt == nil
}
```

#### 3.1.2 Value Objects

Value Objects são imutáveis e identificados por seus valores.

**Exemplo: `core/domain/valueobjects/card_state.go`**

```go
package valueobjects

// CardState representa o estado de um card
type CardState string

const (
    CardStateNew     CardState = "new"
    CardStateLearn   CardState = "learn"
    CardStateReview  CardState = "review"
    CardStateRelearn CardState = "relearn"
)

// IsValid valida se o estado é válido
func (s CardState) IsValid() bool {
    return s == CardStateNew || 
           s == CardStateLearn || 
           s == CardStateReview || 
           s == CardStateRelearn
}

// String retorna a representação em string
func (s CardState) String() string {
    return string(s)
}
```

**Exemplo: `core/domain/valueobjects/email.go`**

```go
package valueobjects

import (
    "errors"
    "regexp"
    "strings"
)

var emailRegex = regexp.MustCompile(`^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$`)

// Email representa um email válido
type Email struct {
    value string
}

// NewEmail cria um novo Email validado
func NewEmail(value string) (Email, error) {
    trimmed := strings.TrimSpace(strings.ToLower(value))
    
    if trimmed == "" {
        return Email{}, errors.New("email não pode ser vazio")
    }
    
    if !emailRegex.MatchString(trimmed) {
        return Email{}, errors.New("email inválido")
    }
    
    return Email{value: trimmed}, nil
}

// Value retorna o valor do email
func (e Email) Value() string {
    return e.value
}

// Equals compara dois emails
func (e Email) Equals(other Email) bool {
    return e.value == other.value
}
```

**Exemplo: `core/domain/valueobjects/password.go`**

```go
package valueobjects

import (
    "errors"
    "golang.org/x/crypto/bcrypt"
    "unicode"
)

// Password representa uma senha segura
type Password struct {
    hash string
}

// NewPassword cria um novo Password com hash
func NewPassword(plainPassword string) (Password, error) {
    if len(plainPassword) < 8 {
        return Password{}, errors.New("senha deve ter no mínimo 8 caracteres")
    }
    
    hasLetter := false
    hasNumber := false
    
    for _, char := range plainPassword {
        if unicode.IsLetter(char) {
            hasLetter = true
        }
        if unicode.IsNumber(char) {
            hasNumber = true
        }
    }
    
    if !hasLetter || !hasNumber {
        return Password{}, errors.New("senha deve conter pelo menos uma letra e um número")
    }
    
    hash, err := bcrypt.GenerateFromPassword([]byte(plainPassword), bcrypt.DefaultCost)
    if err != nil {
        return Password{}, err
    }
    
    return Password{hash: string(hash)}, nil
}

// Hash retorna o hash da senha
func (p Password) Hash() string {
    return p.hash
}

// Verify verifica se a senha plain corresponde ao hash
func (p Password) Verify(plainPassword string) bool {
    err := bcrypt.CompareHashAndPassword([]byte(p.hash), []byte(plainPassword))
    return err == nil
}
```

**Exemplo: `core/domain/valueobjects/guid.go`**

```go
package valueobjects

import (
    "crypto/rand"
    "fmt"
    "regexp"
)

var guidRegex = regexp.MustCompile(`^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`)

// GUID representa um identificador único global
type GUID struct {
    value string
}

// NewGUID cria um novo GUID aleatório
func NewGUID() (GUID, error) {
    b := make([]byte, 16)
    _, err := rand.Read(b)
    if err != nil {
        return GUID{}, err
    }
    
    guid := fmt.Sprintf("%x-%x-%x-%x-%x",
        b[0:4], b[4:6], b[6:8], b[8:10], b[10:])
    
    return GUID{value: guid}, nil
}

// ParseGUID cria um GUID a partir de uma string
func ParseGUID(value string) (GUID, error) {
    if !guidRegex.MatchString(value) {
        return GUID{}, fmt.Errorf("GUID inválido: %s", value)
    }
    return GUID{value: value}, nil
}

// Value retorna o valor do GUID
func (g GUID) Value() string {
    return g.value
}

// Equals compara dois GUIDs
func (g GUID) Equals(other GUID) bool {
    return g.value == other.value
}
```

**Exemplo: `core/domain/valueobjects/deck_options.go`**

```go
package valueobjects

// DeckOptions contém todas as opções de configuração de um deck
type DeckOptions struct {
    PresetID                        *int64
    NewCardsPerDay                  int
    MaxReviewsPerDay                int
    LearningSteps                   []int
    GraduatingInterval              int
    EasyInterval                    int
    RelearningSteps                 []int
    MinimumInterval                 int
    Scheduler                       string // "sm2" ou "fsrs"
    FSRSEnabled                     bool
    DesiredRetention                float64
    FSRSParameters                  *FSRSParameters
    IntervalModifier                float64
    MaximumInterval                 int
    EasyBonus                       float64
    HardInterval                    float64
    NewInterval                     float64
    StartingEase                    float64
    BuryNewSiblings                 bool
    BuryReviewSiblings              bool
    BuryInterdayLearningSiblings   bool
    NewCardGatherOrder              string
    NewCardSortOrder                string
    NewReviewOrder                   string
    ReviewSortOrder                  string
    LeechThreshold                  int
    LeechAction                     string
    AudioAutoPlay                   bool
    AudioReplayButtons              bool
    InterruptAudioOnAnswer          bool
    MaxAnswerSeconds                int
    ShowTimer                       bool
    StopTimerOnAnswer               bool
    AutoAdvanceQuestionSeconds      int
    AutoAdvanceAnswerSeconds        int
    EasyDays                        map[string]string
    CustomScheduling                *string
    RescheduleCardsOnChange         bool
}

// FSRSParameters contém os parâmetros do algoritmo FSRS
type FSRSParameters struct {
    W []float64
}
```

**Exemplo: `core/domain/valueobjects/review_type.go`**

```go
package valueobjects

// ReviewType representa o tipo de revisão
type ReviewType string

const (
    ReviewTypeLearn   ReviewType = "learn"
    ReviewTypeReview  ReviewType = "review"
    ReviewTypeRelearn ReviewType = "relearn"
    ReviewTypeCram    ReviewType = "cram"
)

// IsValid valida se o tipo de revisão é válido
func (rt ReviewType) IsValid() bool {
    return rt == ReviewTypeLearn ||
           rt == ReviewTypeReview ||
           rt == ReviewTypeRelearn ||
           rt == ReviewTypeCram
}
```

#### 3.1.3 Domain Services

Serviços de domínio contêm lógica que não pertence naturalmente a uma entidade.

**Exemplo: `core/domain/services/scheduler.go`**

```go
package services

import (
    "errors"
    "math"
    "time"
    
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/valueobjects"
)

// SchedulerService calcula intervalos usando algoritmos de repetição espaçada
type SchedulerService interface {
    CalculateInterval(
        card *entities.Card,
        rating int,
        deckOptions *valueobjects.DeckOptions,
    ) (*SchedulingResult, error)
}

// SchedulingResult contém o resultado do cálculo de scheduling
type SchedulingResult struct {
    NewInterval int
    NewEase     int
    NewState    valueobjects.CardState
    NewDue      int64
}

// SM2Scheduler implementa o algoritmo SM-2
type SM2Scheduler struct{}

func (s *SM2Scheduler) CalculateInterval(
    card *entities.Card,
    rating int,
    options *valueobjects.DeckOptions,
) (*SchedulingResult, error) {
    result := &SchedulingResult{
        NewEase:  card.Ease,
        NewState: card.State,
    }
    
    now := time.Now().UnixMilli()
    
    switch rating {
    case 1: // Again
        result.NewEase = max(1300, int(float64(card.Ease)*0.8))
        if card.State == valueobjects.CardStateReview {
            result.NewState = valueobjects.CardStateRelearn
            if len(options.RelearningSteps) > 0 {
                result.NewInterval = options.RelearningSteps[0]
                result.NewDue = now + int64(result.NewInterval*1000)
            }
        } else {
            result.NewState = valueobjects.CardStateLearn
            if len(options.LearningSteps) > 0 {
                result.NewInterval = options.LearningSteps[0]
                result.NewDue = now + int64(result.NewInterval*1000)
            }
        }
        
    case 2: // Hard
        if card.State == valueobjects.CardStateReview {
            // Hard em review: novo intervalo = intervalo anterior × hard interval
            newIntervalDays := float64(card.Interval) * options.HardInterval
            result.NewInterval = int(math.Max(1, newIntervalDays))
            result.NewDue = now + int64(result.NewInterval*86400000) // dias em ms
        } else if card.State == valueobjects.CardStateLearn {
            // Hard em learning: repete o step atual
            result.NewInterval = card.Interval
            result.NewDue = now + int64(result.NewInterval*1000)
        }
        
    case 3: // Good
        if card.State == valueobjects.CardStateNew || card.State == valueobjects.CardStateLearn {
            // Avança para próximo learning step ou para review
            currentStepIndex := s.findLearningStepIndex(card.Interval, options.LearningSteps)
            if currentStepIndex < len(options.LearningSteps)-1 {
                // Ainda há steps
                result.NewInterval = options.LearningSteps[currentStepIndex+1]
                result.NewDue = now + int64(result.NewInterval*1000)
                result.NewState = valueobjects.CardStateLearn
            } else {
                // Graduou para review
                result.NewInterval = options.GraduatingInterval
                result.NewDue = now + int64(result.NewInterval*86400000)
                result.NewState = valueobjects.CardStateReview
            }
        } else if card.State == valueobjects.CardStateReview {
            // Good em review: novo intervalo = intervalo anterior × ease × interval modifier
            easeFactor := float64(card.Ease) / 1000.0
            newIntervalDays := float64(card.Interval) * easeFactor * options.IntervalModifier
            result.NewInterval = int(math.Max(float64(options.MinimumInterval), newIntervalDays))
            result.NewInterval = int(math.Min(float64(result.NewInterval), float64(options.MaximumInterval)))
            result.NewDue = now + int64(result.NewInterval*86400000)
        }
        
    case 4: // Easy
        if card.State == valueobjects.CardStateNew || card.State == valueobjects.CardStateLearn {
            // Pula para review com easy interval
            result.NewInterval = options.EasyInterval
            result.NewDue = now + int64(result.NewInterval*86400000)
            result.NewState = valueobjects.CardStateReview
            result.NewEase = min(10000, card.Ease+150) // Aumenta ease
        } else if card.State == valueobjects.CardStateReview {
            // Easy em review: novo intervalo = intervalo anterior × ease × easy bonus × interval modifier
            easeFactor := float64(card.Ease) / 1000.0
            newIntervalDays := float64(card.Interval) * easeFactor * options.EasyBonus * options.IntervalModifier
            result.NewInterval = int(math.Max(float64(options.MinimumInterval), newIntervalDays))
            result.NewInterval = int(math.Min(float64(result.NewInterval), float64(options.MaximumInterval)))
            result.NewDue = now + int64(result.NewInterval*86400000)
            result.NewEase = min(10000, card.Ease+150) // Aumenta ease
        }
    }
    
    return result, nil
}

func (s *SM2Scheduler) findLearningStepIndex(interval int, steps []int) int {
    for i, step := range steps {
        if step == interval {
            return i
        }
    }
    return 0
}

func max(a, b int) int {
    if a > b {
        return a
    }
    return b
}

func min(a, b int) int {
    if a < b {
        return a
    }
    return b
}
```

**Exemplo: `core/domain/services/card_generator.go`**

```go
package services

import (
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/valueobjects"
)

// CardGeneratorService gera cards a partir de notes
type CardGeneratorService interface {
    GenerateCards(
        note *entities.Note,
        noteType *entities.NoteType,
        deckID int64,
    ) ([]*entities.Card, error)
}

// CardGenerator implementa a geração de cards
type CardGenerator struct {
    templateRenderer TemplateRendererService
}

// NewCardGenerator cria um novo CardGenerator
func NewCardGenerator(templateRenderer TemplateRendererService) *CardGenerator {
    return &CardGenerator{
        templateRenderer: templateRenderer,
    }
}

// GenerateCards gera cards baseado no note type
func (g *CardGenerator) GenerateCards(
    note *entities.Note,
    noteType *entities.NoteType,
    deckID int64,
) ([]*entities.Card, error) {
    var cards []*entities.Card
    
    // Para cada card type no note type
    for cardTypeIndex, cardType := range noteType.CardTypes {
        // Renderizar front template
        front, err := g.templateRenderer.RenderFront(cardType.FrontTemplate, note.Fields)
        if err != nil {
            return nil, err
        }
        
        // Se front não estiver vazio, gerar card
        if front != "" {
            card := &entities.Card{
                NoteID:     note.ID,
                CardTypeID: cardTypeIndex,
                DeckID:     deckID,
                State:      valueobjects.CardStateNew,
                Ease:       int(noteType.Options.StartingEase * 1000),
                Position:   0, // Será definido pelo repositório
            }
            
            cards = append(cards, card)
        }
    }
    
    return cards, nil
}
```

**Exemplo: `core/domain/services/template_renderer.go`**

```go
package services

import (
    "bytes"
    "html/template"
    "strings"
)

// TemplateRendererService renderiza templates HTML
type TemplateRendererService interface {
    RenderFront(templateStr string, fields map[string]string) (string, error)
    RenderBack(templateStr string, fields map[string]string) (string, error)
}

// TemplateRenderer implementa a renderização de templates
type TemplateRenderer struct{}

// NewTemplateRenderer cria um novo TemplateRenderer
func NewTemplateRenderer() *TemplateRenderer {
    return &TemplateRenderer{}
}

// RenderFront renderiza o template da frente do card
func (r *TemplateRenderer) RenderFront(templateStr string, fields map[string]string) (string, error) {
    tmpl, err := template.New("front").Parse(templateStr)
    if err != nil {
        return "", err
    }
    
    var buf bytes.Buffer
    err = tmpl.Execute(&buf, fields)
    if err != nil {
        return "", err
    }
    
    return strings.TrimSpace(buf.String()), nil
}

// RenderBack renderiza o template do verso do card
func (r *TemplateRenderer) RenderBack(templateStr string, fields map[string]string) (string, error) {
    // Similar ao RenderFront
    return r.RenderFront(templateStr, fields)
}
```

#### 3.1.4 Repository Interfaces (Ports)

Interfaces definem contratos sem implementação.

**Exemplo: `core/interfaces/secondary/card_repository.go`**

```go
package repositories

import (
    "context"
    "errors"
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/valueobjects"
)

var (
    ErrCardNotFound = errors.New("card não encontrado")
)

// CardRepository define o contrato para persistência de cards
type CardRepository interface {
    // FindByID busca um card por ID
    FindByID(ctx context.Context, id int64) (*entities.Card, error)
    
    // FindByNoteID busca todos os cards de uma note
    FindByNoteID(ctx context.Context, noteID int64) ([]*entities.Card, error)
    
    // FindDueCards busca cards due para estudo
    FindDueCards(
        ctx context.Context,
        deckID int64,
        now int64,
        limit int,
    ) ([]*entities.Card, error)
    
    // FindNewCards busca novos cards disponíveis
    FindNewCards(
        ctx context.Context,
        deckID int64,
        limit int,
    ) ([]*entities.Card, error)
    
    // Save salva ou atualiza um card
    Save(ctx context.Context, card *entities.Card) error
    
    // SaveMany salva múltiplos cards em transação
    SaveMany(ctx context.Context, cards []*entities.Card) error
    
    // Delete exclui um card
    Delete(ctx context.Context, id int64) error
    
    // CountByDeck conta cards por deck e estado
    CountByDeck(
        ctx context.Context,
        deckID int64,
        state valueobjects.CardState,
    ) (int, error)
}
```

**Exemplo: `core/interfaces/secondary/deck_repository.go`**

```go
package repositories

import (
    "context"
    "errors"
    "github.com/anki/core/domain/entities"
)

var (
    ErrDeckNotFound = errors.New("deck não encontrado")
)

// DeckRepository define o contrato para persistência de decks
type DeckRepository interface {
    FindByID(ctx context.Context, id int64) (*entities.Deck, error)
    FindByUserID(ctx context.Context, userID int64) ([]*entities.Deck, error)
    FindByParentID(ctx context.Context, parentID int64) ([]*entities.Deck, error)
    Save(ctx context.Context, deck *entities.Deck) error
    Delete(ctx context.Context, id int64) error
    Exists(ctx context.Context, userID int64, name string, parentID *int64) (bool, error)
}
```

**Exemplo: `core/interfaces/secondary/note_repository.go`**

```go
package repositories

import (
    "context"
    "errors"
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/valueobjects"
)

var (
    ErrNoteNotFound = errors.New("note não encontrada")
)

// NoteRepository define o contrato para persistência de notes
type NoteRepository interface {
    FindByID(ctx context.Context, id int64) (*entities.Note, error)
    FindByGUID(ctx context.Context, guid valueobjects.GUID) (*entities.Note, error)
    FindByUserID(ctx context.Context, userID int64, limit, offset int) ([]*entities.Note, error)
    FindByDeckID(ctx context.Context, deckID int64, limit, offset int) ([]*entities.Note, error)
    Search(ctx context.Context, userID int64, query string, limit, offset int) ([]*entities.Note, error)
    Save(ctx context.Context, note *entities.Note) error
    Delete(ctx context.Context, id int64) error
    FindDuplicates(ctx context.Context, userID int64, noteTypeID int64, firstField string) ([]*entities.Note, error)
}
```

**Exemplo: `core/interfaces/secondary/review_repository.go`**

```go
package repositories

import (
    "context"
    "time"
    "github.com/anki/core/domain/entities"
)

// ReviewRepository define o contrato para persistência de reviews
type ReviewRepository interface {
    Save(ctx context.Context, review *entities.Review) error
    FindByCardID(ctx context.Context, cardID int64, limit int) ([]*entities.Review, error)
    FindByCardIDAndDateRange(
        ctx context.Context,
        cardID int64,
        startDate, endDate time.Time,
    ) ([]*entities.Review, error)
    CountByCardID(ctx context.Context, cardID int64) (int, error)
}
```

**Exemplo: `core/interfaces/secondary/user_repository.go`**

```go
package repositories

import (
    "context"
    "errors"
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/valueobjects"
)

var (
    ErrUserNotFound = errors.New("usuário não encontrado")
    ErrEmailExists  = errors.New("email já cadastrado")
)

// UserRepository define o contrato para persistência de usuários
type UserRepository interface {
    FindByID(ctx context.Context, id int64) (*entities.User, error)
    FindByEmail(ctx context.Context, email valueobjects.Email) (*entities.User, error)
    Save(ctx context.Context, user *entities.User) error
    ExistsByEmail(ctx context.Context, email valueobjects.Email) (bool, error)
    UpdateLastLogin(ctx context.Context, userID int64) error
}
```

#### 3.1.5 Domain Events

**Exemplo: `core/domain/events/card_reviewed.go`**

```go
package events

import (
    "time"
    "github.com/anki/core/domain/valueobjects"
)

// CardReviewed é publicado quando um card é revisado
type CardReviewed struct {
    CardID    int64
    UserID    int64
    Rating    int
    NewState  valueobjects.CardState
    Timestamp time.Time
}

// EventType retorna o tipo do evento
func (e *CardReviewed) EventType() string {
    return "card.reviewed"
}
```

**Exemplo: `core/domain/events/note_created.go`**

```go
package events

import (
    "time"
)

// NoteCreated é publicado quando uma note é criada
type NoteCreated struct {
    NoteID    int64
    UserID    int64
    NoteTypeID int64
    Timestamp time.Time
}

// EventType retorna o tipo do evento
func (e *NoteCreated) EventType() string {
    return "note.created"
}
```

**Exemplo: `core/domain/events/deck_updated.go`**

```go
package events

import (
    "time"
)

// DeckUpdated é publicado quando um deck é atualizado
type DeckUpdated struct {
    DeckID    int64
    UserID    int64
    Timestamp time.Time
}

// EventType retorna o tipo do evento
func (e *DeckUpdated) EventType() string {
    return "deck.updated"
}
```

### 3.2 Application Layer (Aplicação)

**Responsabilidade**: Orquestra casos de uso, coordena entidades de domínio e aplica regras de aplicação.

#### 3.2.1 Application Services

**Exemplo: `core/services/services/study_service.go`**

```go
package services

import (
    "context"
    "errors"
    "time"
    
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/repositories"
    domain_services "github.com/anki/core/domain/services"
    "github.com/anki/core/domain/valueobjects"
)

// EventBus interface para publicação de eventos
type EventBus interface {
    Publish(ctx context.Context, event interface{}) error
}

// StudyService orquestra casos de uso relacionados a estudo
type StudyService struct {
    cardRepo      secondary.ICardRepository
    reviewRepo    repositories.ReviewRepository
    deckRepo      repositories.DeckRepository
    scheduler     domain_services.SchedulerService
    eventBus      EventBus
}

// NewStudyService cria um novo StudyService
func NewStudyService(
    cardRepo secondary.ICardRepository,
    reviewRepo repositories.ReviewRepository,
    deckRepo repositories.DeckRepository,
    scheduler domain_services.SchedulerService,
    eventBus EventBus,
) *StudyService {
    return &StudyService{
        cardRepo:   cardRepo,
        reviewRepo: reviewRepo,
        deckRepo:   deckRepo,
        scheduler:  scheduler,
        eventBus:   eventBus,
    }
}

// AnswerCardResult contém o resultado de responder um card
type AnswerCardResult struct {
    CardID      int64
    NewState    valueobjects.CardState
    NewDue      int64
    NewInterval int
}

// AnswerCard processa a resposta de um card durante estudo
func (s *StudyService) AnswerCard(
    ctx context.Context,
    userID int64,
    cardID int64,
    rating int,
    timeMs int,
) (*AnswerCardResult, error) {
    // 1. Buscar card
    card, err := s.cardRepo.FindByID(ctx, cardID)
    if err != nil {
        return nil, err
    }
    
    // 2. Validar ownership (através do deck)
    deck, err := s.deckRepo.FindByID(ctx, card.DeckID)
    if err != nil {
        return nil, err
    }
    
    if deck.UserID != userID {
        return nil, errors.New("card não pertence ao usuário")
    }
    
    // 3. Buscar opções do deck
    deckOptions := deck.Options
    
    // 4. Calcular novo intervalo usando scheduler
    now := time.Now().UnixMilli()
    result, err := s.scheduler.CalculateInterval(card, rating, deckOptions)
    if err != nil {
        return nil, err
    }
    
    // 5. Atualizar card
    card.MarkAsReviewed(rating, result.NewInterval, result.NewEase)
    card.State = result.NewState
    card.Due = result.NewDue
    
    if err := s.cardRepo.Save(ctx, card); err != nil {
        return nil, err
    }
    
    // 6. Criar registro de review
    review := &entities.Review{
        CardID:   cardID,
        Rating:   rating,
        Interval: result.NewInterval,
        Ease:     result.NewEase,
        TimeMs:   timeMs,
        Type:     mapStateToReviewType(card.State),
    }
    
    if err := s.reviewRepo.Save(ctx, review); err != nil {
        return nil, err
    }
    
    // 7. Publicar evento de domínio
    s.eventBus.Publish(ctx, &events.CardReviewed{
        CardID:    cardID,
        UserID:    userID,
        Rating:    rating,
        NewState:  result.NewState,
        Timestamp: time.Now(),
    })
    
    return &AnswerCardResult{
        CardID:      cardID,
        NewState:    result.NewState,
        NewDue:      result.NewDue,
        NewInterval: result.NewInterval,
    }, nil
}

// mapStateToReviewType mapeia estado do card para tipo de revisão
func mapStateToReviewType(state valueobjects.CardState) valueobjects.ReviewType {
    switch state {
    case valueobjects.CardStateLearn:
        return valueobjects.ReviewTypeLearn
    case valueobjects.CardStateReview:
        return valueobjects.ReviewTypeReview
    case valueobjects.CardStateRelearn:
        return valueobjects.ReviewTypeRelearn
    default:
        return valueobjects.ReviewTypeReview
    }
}
```

**Exemplo: `core/services/services/deck_service.go`**

```go
package services

import (
    "context"
    "errors"
    "time"
    
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/repositories"
    "github.com/anki/core/domain/valueobjects"
)

// DeckService orquestra casos de uso relacionados a decks
type DeckService struct {
    deckRepo repositories.DeckRepository
}

// NewDeckService cria um novo DeckService
func NewDeckService(deckRepo repositories.DeckRepository) *DeckService {
    return &DeckService{
        deckRepo: deckRepo,
    }
}

// CreateDeck cria um novo deck
func (s *DeckService) CreateDeck(
    ctx context.Context,
    userID int64,
    name string,
    parentID *int64,
    options *valueobjects.DeckOptions,
) (*entities.Deck, error) {
    // Verificar se nome já existe no mesmo nível
    exists, err := s.deckRepo.Exists(ctx, userID, name, parentID)
    if err != nil {
        return nil, err
    }
    
    if exists {
        return nil, errors.New("deck com este nome já existe neste nível")
    }
    
    deck := &entities.Deck{
        UserID:    userID,
        Name:      name,
        ParentID:  parentID,
        Options:   options,
        CreatedAt: time.Now(),
        UpdatedAt: time.Now(),
    }
    
    if err := s.deckRepo.Save(ctx, deck); err != nil {
        return nil, err
    }
    
    return deck, nil
}
```

**Exemplo: `core/services/services/note_service.go`**

```go
package services

import (
    "context"
    "errors"
    "time"
    
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/repositories"
    domain_services "github.com/anki/core/domain/services"
)

// NoteService orquestra casos de uso relacionados a notes
type NoteService struct {
    noteRepo        repositories.NoteRepository
    cardRepo        secondary.ICardRepository
    cardGenerator   domain_services.CardGeneratorService
}

// NewNoteService cria um novo NoteService
func NewNoteService(
    noteRepo repositories.NoteRepository,
    cardRepo secondary.ICardRepository,
    cardGenerator domain_services.CardGeneratorService,
) *NoteService {
    return &NoteService{
        noteRepo:      noteRepo,
        cardRepo:      cardRepo,
        cardGenerator: cardGenerator,
    }
}

// CreateNote cria uma nova note e gera os cards
func (s *NoteService) CreateNote(
    ctx context.Context,
    userID int64,
    noteTypeID int64,
    deckID int64,
    fields map[string]string,
    tags []string,
) (*entities.Note, error) {
    // Criar note
    note := &entities.Note{
        UserID:     userID,
        NoteTypeID: noteTypeID,
        Fields:     fields,
        Tags:       tags,
        Marked:     false,
        CreatedAt:  time.Now(),
        UpdatedAt:  time.Now(),
    }
    
    // Gerar GUID
    guid, err := valueobjects.NewGUID()
    if err != nil {
        return nil, err
    }
    note.GUID = guid
    
    // Salvar note
    if err := s.noteRepo.Save(ctx, note); err != nil {
        return nil, err
    }
    
    // Buscar note type (seria necessário um NoteTypeRepository)
    // Por enquanto, assumimos que o note type existe
    
    // Gerar cards
    // cards, err := s.cardGenerator.GenerateCards(note, noteType, deckID)
    // if err != nil {
    //     return nil, err
    // }
    
    // Salvar cards
    // if err := s.cardRepo.SaveMany(ctx, cards); err != nil {
    //     return nil, err
    // }
    
    return note, nil
}
```

#### 3.2.2 DTOs (Data Transfer Objects)

**Exemplo: `core/services/dto/study_dto.go`**

```go
package dto

// AnswerCardRequest representa a requisição para responder um card
type AnswerCardRequest struct {
    CardID  int64 `json:"card_id"`
    Rating  int   `json:"rating"`  // 1=Again, 2=Hard, 3=Good, 4=Easy
    TimeMs  int   `json:"time_ms"`
}

// AnswerCardResponse representa a resposta de responder um card
type AnswerCardResponse struct {
    CardID      int64  `json:"card_id"`
    NewState    string `json:"new_state"`
    NewDue      int64  `json:"new_due"`
    NewInterval int    `json:"new_interval"`
}
```

**Exemplo: `core/services/dto/deck_dto.go`**

```go
package dto

// CreateDeckRequest representa a requisição para criar um deck
type CreateDeckRequest struct {
    Name     string                 `json:"name"`
    ParentID *int64                 `json:"parent_id,omitempty"`
    Options  map[string]interface{} `json:"options,omitempty"`
}

// DeckResponse representa um deck na resposta
type DeckResponse struct {
    ID        int64                  `json:"id"`
    Name      string                 `json:"name"`
    ParentID  *int64                 `json:"parent_id,omitempty"`
    Options   map[string]interface{} `json:"options"`
    CreatedAt string                 `json:"created_at"`
    UpdatedAt string                 `json:"updated_at"`
}
```

#### 3.2.3 Mappers (Mapper Pattern)

O **Mapper Pattern** é usado para converter entre diferentes representações de dados (Domain ↔ Database ↔ DTO).

**Benefícios**:
- ✅ Separação de responsabilidades (conversão isolada)
- ✅ Reutilização (lógica de conversão centralizada)
- ✅ Testabilidade (testar conversões independentemente)
- ✅ Manutenibilidade (mudanças em uma representação não afetam outras)

**Exemplo: `infra/persistence/postgres/mappers/card_mapper.go`**

```go
package mappers

import (
    "database/sql"
    "time"
    
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/valueobjects"
)

// CardMapper converte entre Domain e Database models
type CardMapper struct{}

// ToDomain converte database model para domain entity
func (m *CardMapper) ToDomain(
    id, noteID, cardTypeID, deckID int64,
    due, interval, ease, lapses, reps, position, flag int,
    suspended, buried bool,
    state string,
    stability, difficulty *float64,
    lastReviewAt *time.Time,
    createdAt, updatedAt time.Time,
) *entities.Card {
    card := &entities.Card{
        ID:          id,
        NoteID:      noteID,
        CardTypeID:  cardTypeID,
        DeckID:      deckID,
        Due:         int64(due),
        Interval:    interval,
        Ease:        ease,
        Lapses:      lapses,
        Reps:        reps,
        Position:    position,
        Flag:        flag,
        Suspended:   suspended,
        Buried:      buried,
        Stability:   stability,
        Difficulty:  difficulty,
        LastReviewAt: lastReviewAt,
        CreatedAt:   createdAt,
        UpdatedAt:   updatedAt,
    }
    
    // Converter string para CardState value object
    card.State = valueobjects.CardState(state)
    
    return card
}

// ScanCard escaneia row do banco para Card entity
func ScanCard(rows *sql.Rows, card *entities.Card) error {
    var state string
    var lastReviewAt sql.NullTime
    
    err := rows.Scan(
        &card.ID,
        &card.NoteID,
        &card.CardTypeID,
        &card.DeckID,
        &card.Due,
        &card.Interval,
        &card.Ease,
        &card.Lapses,
        &card.Reps,
        &state,
        &card.Position,
        &card.Flag,
        &card.Suspended,
        &card.Buried,
        &card.Stability,
        &card.Difficulty,
        &lastReviewAt,
        &card.CreatedAt,
        &card.UpdatedAt,
    )
    if err != nil {
        return err
    }
    
    card.State = valueobjects.CardState(state)
    if lastReviewAt.Valid {
        card.LastReviewAt = &lastReviewAt.Time
    }
    
    return nil
}

// ToDatabase converte domain entity para valores de database
func (m *CardMapper) ToDatabase(card *entities.Card) ([]interface{}, error) {
    return []interface{}{
        card.NoteID,
        card.CardTypeID,
        card.DeckID,
        card.Due,
        card.Interval,
        card.Ease,
        card.Lapses,
        card.Reps,
        string(card.State),
        card.Position,
        card.Flag,
        card.Suspended,
        card.Buried,
        card.Stability,
        card.Difficulty,
        card.LastReviewAt,
    }, nil
}
```

**Exemplo: `core/services/mappers/card_mapper.go` (Domain ↔ DTO)**

```go
package mappers

import (
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/services/dto"
)

// CardAPIMapper converte entre Domain e DTOs
type CardAPIMapper struct{}

// ToResponse converte domain entity para response DTO
func (m *CardAPIMapper) ToResponse(card *entities.Card) *dto.CardResponse {
    return &dto.CardResponse{
        ID:          card.ID,
        NoteID:      card.NoteID,
        CardTypeID:  card.CardTypeID,
        DeckID:      card.DeckID,
        Due:         card.Due,
        Interval:    card.Interval,
        Ease:        card.Ease,
        Lapses:      card.Lapses,
        Reps:        card.Reps,
        State:       string(card.State),
        Position:    card.Position,
        Flag:        card.Flag,
        Suspended:   card.Suspended,
        Buried:      card.Buried,
        CreatedAt:   card.CreatedAt,
        UpdatedAt:   card.UpdatedAt,
    }
}

// ToDomain converte request DTO para domain entity
func (m *CardAPIMapper) ToDomain(req *dto.CreateCardRequest) *entities.Card {
    return &entities.Card{
        NoteID:     req.NoteID,
        CardTypeID: req.CardTypeID,
        DeckID:     req.DeckID,
        State:      valueobjects.CardStateNew,
    }
}

// ToResponseList converte lista de entities para lista de DTOs
func (m *CardAPIMapper) ToResponseList(cards []*entities.Card) []*dto.CardResponse {
    responses := make([]*dto.CardResponse, len(cards))
    for i, card := range cards {
        responses[i] = m.ToResponse(card)
    }
    return responses
}
```

**Uso no Repository**:

```go
func (r *CardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    query := `SELECT id, note_id, card_type_id, deck_id, due, interval, ease, 
                     lapses, reps, state, position, flag, suspended, buried,
                     stability, difficulty, last_review_at, created_at, updated_at
              FROM cards WHERE id = $1`
    
    row := r.db.QueryRowContext(ctx, query, id)
    
    card := &entities.Card{}
    if err := mappers.ScanCard(row, card); err != nil {
        if err == sql.ErrNoRows {
            return nil, nil
        }
        return nil, err
    }
    
    return card, nil
}
```

**Uso no Handler**:

```go
func (h *CardHandler) GetCard(w http.ResponseWriter, r *http.Request) {
    cardID := getCardIDFromPath(r.URL.Path)
    
    card, err := h.service.GetCard(r.Context(), cardID)
    if err != nil {
        middleware.HandleError(w, err)
        return
    }
    
    // Converter domain para DTO usando mapper
    response := mappers.CardAPIMapper{}.ToResponse(card)
    
    json.NewEncoder(w).Encode(response)
}
```

**Exemplo: `core/services/mappers/deck_mapper.go`**

```go
package mappers

import (
    "time"
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/services/dto"
)

// DeckToDTO converte uma entidade Deck para DTO
func DeckToDTO(deck *entities.Deck) *dto.DeckResponse {
    return &dto.DeckResponse{
        ID:        deck.ID,
        Name:      deck.Name,
        ParentID:  deck.ParentID,
        Options:   deckOptionsToMap(deck.Options),
        CreatedAt: deck.CreatedAt.Format(time.RFC3339),
        UpdatedAt: deck.UpdatedAt.Format(time.RFC3339),
    }
}

// deckOptionsToMap converte DeckOptions para map
func deckOptionsToMap(options *valueobjects.DeckOptions) map[string]interface{} {
    // Implementação de conversão
    return make(map[string]interface{})
}
```

### 3.3 Infrastructure Layer (Infraestrutura)

**Responsabilidade**: Implementa adapters para tecnologias externas.

#### 3.3.1 Repository Implementation

**Exemplo: `infra/persistence/postgres/card_repository.go`**

```go
package postgres

import (
    "context"
    "database/sql"
    "time"
    
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/repositories"
    "github.com/anki/core/domain/valueobjects"
)

type cardRepository struct {
    db *sql.DB
}

// NewCardRepository cria uma nova implementação de CardRepository
func NewCardRepository(db *sql.DB) secondary.ICardRepository {
    return &cardRepository{db: db}
}

func (r *cardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    query := `
        SELECT id, note_id, card_type_id, deck_id, home_deck_id,
               due, interval, ease, lapses, reps, state, position,
               flag, suspended, buried, stability, difficulty,
               last_review_at, created_at, updated_at
        FROM cards
        WHERE id = $1
    `
    
    var card entities.Card
    var homeDeckID sql.NullInt64
    var stability, difficulty sql.NullFloat64
    var lastReviewAt sql.NullTime
    
    err := r.db.QueryRowContext(ctx, query, id).Scan(
        &card.ID, &card.NoteID, &card.CardTypeID, &card.DeckID, &homeDeckID,
        &card.Due, &card.Interval, &card.Ease, &card.Lapses, &card.Reps,
        &card.State, &card.Position, &card.Flag, &card.Suspended, &card.Buried,
        &stability, &difficulty, &lastReviewAt,
        &card.CreatedAt, &card.UpdatedAt,
    )
    
    if err != nil {
        if err == sql.ErrNoRows {
            return nil, repositories.ErrCardNotFound
        }
        return nil, err
    }
    
    if homeDeckID.Valid {
        card.HomeDeckID = &homeDeckID.Int64
    }
    if stability.Valid {
        card.Stability = &stability.Float64
    }
    if difficulty.Valid {
        card.Difficulty = &difficulty.Float64
    }
    if lastReviewAt.Valid {
        card.LastReviewAt = &lastReviewAt.Time
    }
    
    return &card, nil
}

func (r *cardRepository) FindDueCards(
    ctx context.Context,
    deckID int64,
    now int64,
    limit int,
) ([]*entities.Card, error) {
    query := `
        SELECT id, note_id, card_type_id, deck_id, home_deck_id,
               due, interval, ease, lapses, reps, state, position,
               flag, suspended, buried, stability, difficulty,
               last_review_at, created_at, updated_at
        FROM cards
        WHERE deck_id = $1
          AND suspended = FALSE
          AND buried = FALSE
          AND (
            (state = 'new')
            OR (state IN ('learn', 'relearn') AND due <= $2)
            OR (state = 'review' AND due <= $2)
          )
        ORDER BY 
          CASE state
            WHEN 'learn' THEN 1
            WHEN 'relearn' THEN 2
            WHEN 'review' THEN 3
            WHEN 'new' THEN 4
          END,
          due ASC
        LIMIT $3
    `
    
    rows, err := r.db.QueryContext(ctx, query, deckID, now, limit)
    if err != nil {
        return nil, err
    }
    defer rows.Close()
    
    var cards []*entities.Card
    for rows.Next() {
        card, err := r.scanCard(rows)
        if err != nil {
            return nil, err
        }
        cards = append(cards, card)
    }
    
    return cards, rows.Err()
}

func (r *cardRepository) scanCard(rows *sql.Rows) (*entities.Card, error) {
    var card entities.Card
    var homeDeckID sql.NullInt64
    var stability, difficulty sql.NullFloat64
    var lastReviewAt sql.NullTime
    
    err := rows.Scan(
        &card.ID, &card.NoteID, &card.CardTypeID, &card.DeckID, &homeDeckID,
        &card.Due, &card.Interval, &card.Ease, &card.Lapses, &card.Reps,
        &card.State, &card.Position, &card.Flag, &card.Suspended, &card.Buried,
        &stability, &difficulty, &lastReviewAt,
        &card.CreatedAt, &card.UpdatedAt,
    )
    
    if err != nil {
        return nil, err
    }
    
    if homeDeckID.Valid {
        card.HomeDeckID = &homeDeckID.Int64
    }
    if stability.Valid {
        card.Stability = &stability.Float64
    }
    if difficulty.Valid {
        card.Difficulty = &difficulty.Float64
    }
    if lastReviewAt.Valid {
        card.LastReviewAt = &lastReviewAt.Time
    }
    
    return &card, nil
}

func (r *cardRepository) FindByNoteID(ctx context.Context, noteID int64) ([]*entities.Card, error) {
    query := `
        SELECT id, note_id, card_type_id, deck_id, home_deck_id,
               due, interval, ease, lapses, reps, state, position,
               flag, suspended, buried, stability, difficulty,
               last_review_at, created_at, updated_at
        FROM cards
        WHERE note_id = $1
        ORDER BY card_type_id
    `
    
    rows, err := r.db.QueryContext(ctx, query, noteID)
    if err != nil {
        return nil, err
    }
    defer rows.Close()
    
    var cards []*entities.Card
    for rows.Next() {
        card, err := r.scanCard(rows)
        if err != nil {
            return nil, err
        }
        cards = append(cards, card)
    }
    
    return cards, rows.Err()
}

func (r *cardRepository) FindNewCards(
    ctx context.Context,
    deckID int64,
    limit int,
) ([]*entities.Card, error) {
    query := `
        SELECT id, note_id, card_type_id, deck_id, home_deck_id,
               due, interval, ease, lapses, reps, state, position,
               flag, suspended, buried, stability, difficulty,
               last_review_at, created_at, updated_at
        FROM cards
        WHERE deck_id = $1
          AND state = 'new'
          AND suspended = FALSE
          AND buried = FALSE
        ORDER BY position ASC
        LIMIT $2
    `
    
    rows, err := r.db.QueryContext(ctx, query, deckID, limit)
    if err != nil {
        return nil, err
    }
    defer rows.Close()
    
    var cards []*entities.Card
    for rows.Next() {
        card, err := r.scanCard(rows)
        if err != nil {
            return nil, err
        }
        cards = append(cards, card)
    }
    
    return cards, rows.Err()
}

func (r *cardRepository) Save(ctx context.Context, card *entities.Card) error {
    if card.ID == 0 {
        return r.insert(ctx, card)
    }
    return r.update(ctx, card)
}

func (r *cardRepository) insert(ctx context.Context, card *entities.Card) error {
    query := `
        INSERT INTO cards (
            note_id, card_type_id, deck_id, home_deck_id,
            due, interval, ease, lapses, reps, state, position,
            flag, suspended, buried, stability, difficulty,
            last_review_at, created_at, updated_at
        ) VALUES (
            $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11,
            $12, $13, $14, $15, $16, $17, $18, $19
        ) RETURNING id
    `
    
    card.CreatedAt = time.Now()
    card.UpdatedAt = time.Now()
    
    err := r.db.QueryRowContext(ctx, query,
        card.NoteID, card.CardTypeID, card.DeckID, card.HomeDeckID,
        card.Due, card.Interval, card.Ease, card.Lapses, card.Reps,
        card.State, card.Position, card.Flag, card.Suspended, card.Buried,
        card.Stability, card.Difficulty, card.LastReviewAt,
        card.CreatedAt, card.UpdatedAt,
    ).Scan(&card.ID)
    
    return err
}

func (r *cardRepository) update(ctx context.Context, card *entities.Card) error {
    query := `
        UPDATE cards SET
            note_id = $2, card_type_id = $3, deck_id = $4, home_deck_id = $5,
            due = $6, interval = $7, ease = $8, lapses = $9, reps = $10,
            state = $11, position = $12, flag = $13, suspended = $14,
            buried = $15, stability = $16, difficulty = $17,
            last_review_at = $18, updated_at = $19
        WHERE id = $1
    `
    
    card.UpdatedAt = time.Now()
    
    _, err := r.db.ExecContext(ctx, query,
        card.ID, card.NoteID, card.CardTypeID, card.DeckID, card.HomeDeckID,
        card.Due, card.Interval, card.Ease, card.Lapses, card.Reps,
        card.State, card.Position, card.Flag, card.Suspended, card.Buried,
        card.Stability, card.Difficulty, card.LastReviewAt,
        card.UpdatedAt,
    )
    
    return err
}

func (r *cardRepository) SaveMany(ctx context.Context, cards []*entities.Card) error {
    tx, err := r.db.BeginTx(ctx, nil)
    if err != nil {
        return err
    }
    defer tx.Rollback()
    
    for _, card := range cards {
        if err := r.Save(ctx, card); err != nil {
            return err
        }
    }
    
    return tx.Commit()
}

func (r *cardRepository) Delete(ctx context.Context, id int64) error {
    query := `DELETE FROM cards WHERE id = $1`
    _, err := r.db.ExecContext(ctx, query, id)
    return err
}

func (r *cardRepository) CountByDeck(
    ctx context.Context,
    deckID int64,
    state valueobjects.CardState,
) (int, error) {
    query := `
        SELECT COUNT(*)
        FROM cards
        WHERE deck_id = $1
          AND state = $2
          AND suspended = FALSE
          AND buried = FALSE
    `
    
    var count int
    err := r.db.QueryRowContext(ctx, query, deckID, state).Scan(&count)
    return count, err
}
```

### 3.4 Interfaces Layer (Interface)

**Responsabilidade**: Expõe a aplicação através de protocolos externos (HTTP, WebSocket).

#### 3.4.1 HTTP Handlers

**Exemplo: `app/api/http/handlers/study_handler.go`**

```go
package handlers

import (
    "encoding/json"
    "net/http"
    
    "github.com/anki/core/services/services"
    "github.com/anki/core/services/dto"
    "github.com/anki/core/domain/repositories"
    "github.com/anki/pkg/errors"
)

type StudyHandler struct {
    studyService *services.StudyService
}

func NewStudyHandler(studyService *services.StudyService) *StudyHandler {
    return &StudyHandler{studyService: studyService}
}

// AnswerCardHandler processa resposta de um card
func (h *StudyHandler) AnswerCardHandler(w http.ResponseWriter, r *http.Request) {
    var req dto.AnswerCardRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        errors.RespondError(w, http.StatusBadRequest, "invalid request body")
        return
    }
    
    // Validar rating
    if req.Rating < 1 || req.Rating > 4 {
        errors.RespondError(w, http.StatusBadRequest, "rating must be between 1 and 4")
        return
    }
    
    // Obter userID do contexto (setado pelo auth middleware)
    userID, ok := r.Context().Value("userID").(int64)
    if !ok {
        errors.RespondError(w, http.StatusUnauthorized, "user not authenticated")
        return
    }
    
    result, err := h.studyService.AnswerCard(
        r.Context(),
        userID,
        req.CardID,
        req.Rating,
        req.TimeMs,
    )
    
    if err != nil {
        if err == repositories.ErrCardNotFound {
            errors.RespondError(w, http.StatusNotFound, "card not found")
            return
        }
        errors.RespondError(w, http.StatusInternalServerError, err.Error())
        return
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(map[string]interface{}{
        "data": result,
    })
}
```

**Exemplo: `app/api/http/middleware/auth_middleware.go`**

```go
package middleware

import (
    "context"
    "net/http"
    "strings"
    
    "github.com/anki/pkg/jwt"
)

type contextKey string

const userIDKey contextKey = "userID"

// AuthMiddleware valida tokens JWT e adiciona userID ao contexto
func AuthMiddleware(jwtService *jwt.Service) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            authHeader := r.Header.Get("Authorization")
            if authHeader == "" {
                http.Error(w, "Authorization header required", http.StatusUnauthorized)
                return
            }
            
            parts := strings.Split(authHeader, " ")
            if len(parts) != 2 || parts[0] != "Bearer" {
                http.Error(w, "Invalid authorization header", http.StatusUnauthorized)
                return
            }
            
            token := parts[1]
            claims, err := jwtService.ValidateToken(token)
            if err != nil {
                http.Error(w, "Invalid token", http.StatusUnauthorized)
                return
            }
            
            userID := int64(claims["user_id"].(float64))
            ctx := context.WithValue(r.Context(), userIDKey, userID)
            
            next.ServeHTTP(w, r.WithContext(ctx))
        })
    }
}
```

**Exemplo: `app/api/http/router.go`**

```go
package http

import (
    "net/http"
    
    "github.com/anki/app/api/handlers"
    "github.com/anki/app/api/middleware"
    "github.com/anki/pkg/jwt"
    "github.com/gorilla/mux"
)

// SetupRouter configura todas as rotas da aplicação
func SetupRouter(
    authHandler *handlers.AuthHandler,
    deckHandler *handlers.DeckHandler,
    noteHandler *handlers.NoteHandler,
    studyHandler *handlers.StudyHandler,
    jwtService *jwt.Service,
) http.Handler {
    router := mux.NewRouter()
    
    // Middleware global
    router.Use(middleware.LoggingMiddleware())
    router.Use(middleware.ErrorMiddleware())
    
    // Rotas públicas
    api := router.PathPrefix("/api/v1").Subrouter()
    api.HandleFunc("/auth/register", authHandler.Register).Methods("POST")
    api.HandleFunc("/auth/login", authHandler.Login).Methods("POST")
    
    // Rotas protegidas
    protected := api.PathPrefix("").Subrouter()
    protected.Use(middleware.AuthMiddleware(jwtService))
    
    // Decks
    protected.HandleFunc("/decks", deckHandler.List).Methods("GET")
    protected.HandleFunc("/decks", deckHandler.Create).Methods("POST")
    protected.HandleFunc("/decks/{id}", deckHandler.Get).Methods("GET")
    protected.HandleFunc("/decks/{id}", deckHandler.Update).Methods("PUT")
    protected.HandleFunc("/decks/{id}", deckHandler.Delete).Methods("DELETE")
    
    // Notes
    protected.HandleFunc("/notes", noteHandler.List).Methods("GET")
    protected.HandleFunc("/notes", noteHandler.Create).Methods("POST")
    protected.HandleFunc("/notes/{id}", noteHandler.Get).Methods("GET")
    protected.HandleFunc("/notes/{id}", noteHandler.Update).Methods("PUT")
    protected.HandleFunc("/notes/{id}", noteHandler.Delete).Methods("DELETE")
    
    // Study
    protected.HandleFunc("/study/answer", studyHandler.AnswerCardHandler).Methods("POST")
    protected.HandleFunc("/study/next-card", studyHandler.NextCardHandler).Methods("GET")
    
    return router
}
```

## 4. API Design Guide

### 4.1 REST API Design Best Practices

#### 4.1.1 Resource Naming Conventions

```go
// ✅ GOOD: Use nouns (not verbs), plural form, lowercase, hyphens
GET    /api/v1/decks
GET    /api/v1/decks/{id}
POST   /api/v1/decks
PUT    /api/v1/decks/{id}
PATCH  /api/v1/decks/{id}
DELETE /api/v1/decks/{id}

// Nested resources (relationships)
GET    /api/v1/decks/{id}/cards          // Deck's cards
GET    /api/v1/cards/{id}/reviews        // Card's reviews
POST   /api/v1/decks/{id}/cards         // Add card to deck

// Sub-resources for actions
POST   /api/v1/users/{id}/password-reset // Reset password
POST   /api/v1/cards/{id}/suspend       // Suspend card
POST   /api/v1/cards/{id}/bury         // Bury card

// Collections and filtering
GET    /api/v1/cards?deck_id=123&state=due&sort=-due&page=1&page_size=20
GET    /api/v1/notes?tag=vocabulary&search=hello

// ❌ BAD: Verbs, singular, mixed case
POST   /api/v1/getDeck
POST   /api/v1/createDeck
POST   /api/v1/deck-delete/{id}
GET    /api/v1/DeckList
```

#### 4.1.2 HTTP Methods & Status Codes

**Exemplo: `app/api/http/handlers/deck_handler.go`**

```go
package handlers

import (
    "encoding/json"
    "net/http"
    "strconv"
    
    "github.com/gorilla/mux"
    "github.com/anki/core/services/services"
    "github.com/anki/core/services/dto"
    "github.com/anki/core/services/filters"
    "github.com/anki/pkg/errors"
)

type DeckHandler struct {
    service *services.DeckService
}

// ListDecks - GET /api/v1/decks
// Returns: 200 OK with list of decks (can be empty)
func (h *DeckHandler) ListDecks(w http.ResponseWriter, r *http.Request) {
    // Parse query parameters
    filter := &filters.DeckFilter{
        BaseFilter: filters.BaseFilter{
            Page:     getIntQuery(r, "page", 1),
            PageSize: getIntQuery(r, "page_size", 20),
            SortBy:   getStringQuery(r, "sort_by", "created_at"),
            SortOrder: getStringQuery(r, "sort_order", "desc"),
        },
        UserID: getInt64Query(r, "user_id", 0),
        Search: getStringQuery(r, "search", ""),
    }
    
    userID := getUserIDFromContext(r.Context())
    decks, total, err := h.service.ListDecks(r.Context(), userID, filter)
    if err != nil {
        errors.RespondError(w, http.StatusInternalServerError, err.Error())
        return
    }
    
    // Paginated response
    response := dto.PaginatedResponse{
        Data: decks,
        Meta: dto.PaginationMeta{
            Page:       filter.Page,
            PageSize:   filter.PageSize,
            Total:      total,
            TotalPages: (total + filter.PageSize - 1) / filter.PageSize,
        },
    }
    
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusOK)
    json.NewEncoder(w).Encode(response)
}

// GetDeck - GET /api/v1/decks/{id}
// Returns: 200 OK (found) or 404 Not Found
func (h *DeckHandler) GetDeck(w http.ResponseWriter, r *http.Request) {
    vars := mux.Vars(r)
    deckID, _ := strconv.ParseInt(vars["id"], 10, 64)
    
    userID := getUserIDFromContext(r.Context())
    
    deck, err := h.service.GetDeck(r.Context(), userID, deckID)
    if err != nil {
        if errors.IsNotFound(err) {
            errors.RespondError(w, http.StatusNotFound, "Deck not found")
            return
        }
        errors.RespondError(w, http.StatusInternalServerError, err.Error())
        return
    }
    
    if deck == nil {
        errors.RespondError(w, http.StatusNotFound, "Deck not found")
        return
    }
    
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusOK)
    json.NewEncoder(w).Encode(dto.DeckToResponse(deck))
}

// CreateDeck - POST /api/v1/decks
// Returns: 201 Created or 400 Bad Request or 409 Conflict
func (h *DeckHandler) CreateDeck(w http.ResponseWriter, r *http.Request) {
    var req dto.CreateDeckRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        errors.RespondError(w, http.StatusBadRequest, "Invalid request body")
        return
    }
    
    // Validate
    if req.Name == "" {
        errors.RespondError(w, http.StatusBadRequest, "Deck name is required")
        return
    }
    
    userID := getUserIDFromContext(r.Context())
    
    deck := &entities.Deck{
        UserID: userID,
        Name:   req.Name,
        ParentID: req.ParentID,
    }
    
    saved, err := h.service.CreateDeck(r.Context(), deck)
    if err != nil {
        if errors.IsConflict(err) {
            errors.RespondError(w, http.StatusConflict, "Deck with this name already exists")
            return
        }
        if errors.IsValidation(err) {
            errors.RespondError(w, http.StatusBadRequest, err.Error())
            return
        }
        errors.RespondError(w, http.StatusInternalServerError, err.Error())
        return
    }
    
    // Set Location header
    w.Header().Set("Location", fmt.Sprintf("/api/v1/decks/%d", saved.ID))
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusCreated)
    json.NewEncoder(w).Encode(dto.DeckToResponse(saved))
}

// UpdateDeck - PUT /api/v1/decks/{id}
// Returns: 200 OK or 404 Not Found or 400 Bad Request
func (h *DeckHandler) UpdateDeck(w http.ResponseWriter, r *http.Request) {
    vars := mux.Vars(r)
    deckID, _ := strconv.ParseInt(vars["id"], 10, 64)
    
    var req dto.UpdateDeckRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        errors.RespondError(w, http.StatusBadRequest, "Invalid request body")
        return
    }
    
    userID := getUserIDFromContext(r.Context())
    
    deck, err := h.service.UpdateDeck(r.Context(), userID, deckID, &req)
    if err != nil {
        if errors.IsNotFound(err) {
            errors.RespondError(w, http.StatusNotFound, "Deck not found")
            return
        }
        errors.RespondError(w, http.StatusInternalServerError, err.Error())
        return
    }
    
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusOK)
    json.NewEncoder(w).Encode(dto.DeckToResponse(deck))
}

// DeleteDeck - DELETE /api/v1/decks/{id}
// Returns: 204 No Content or 404 Not Found
func (h *DeckHandler) DeleteDeck(w http.ResponseWriter, r *http.Request) {
    vars := mux.Vars(r)
    deckID, _ := strconv.ParseInt(vars["id"], 10, 64)
    
    userID := getUserIDFromContext(r.Context())
    
    err := h.service.DeleteDeck(r.Context(), userID, deckID)
    if err != nil {
        if errors.IsNotFound(err) {
            errors.RespondError(w, http.StatusNotFound, "Deck not found")
            return
        }
        errors.RespondError(w, http.StatusInternalServerError, err.Error())
        return
    }
    
    w.WriteHeader(http.StatusNoContent)
}
```

### 4.2 API Versioning

#### 4.2.1 URL Versioning

**Exemplo: `app/api/http/router.go`**

```go
package http

import (
    "github.com/gorilla/mux"
    "github.com/anki/app/api/handlers"
    "github.com/anki/app/api/middleware"
)

func SetupRouter() *mux.Router {
    router := mux.NewRouter()
    
    // API v1
    v1 := router.PathPrefix("/api/v1").Subrouter()
    setupV1Routes(v1)
    
    // API v2 (future)
    v2 := router.PathPrefix("/api/v2").Subrouter()
    setupV2Routes(v2)
    
    return router
}

func setupV1Routes(r *mux.Router) {
    deckHandler := handlers.NewDeckHandler(serviceFactory)
    
    r.HandleFunc("/decks", deckHandler.ListDecks).Methods("GET")
    r.HandleFunc("/decks", deckHandler.CreateDeck).Methods("POST")
    r.HandleFunc("/decks/{id}", deckHandler.GetDeck).Methods("GET")
    r.HandleFunc("/decks/{id}", deckHandler.UpdateDeck).Methods("PUT")
    r.HandleFunc("/decks/{id}", deckHandler.DeleteDeck).Methods("DELETE")
}
```

#### 4.2.2 Deprecation Strategy

**Exemplo: `app/api/http/middleware/deprecation_middleware.go`**

```go
package middleware

import "net/http"

// DeprecationMiddleware adiciona headers de deprecation
func DeprecationMiddleware(version string, sunsetDate string) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            w.Header().Set("Deprecation", "true")
            w.Header().Set("Sunset", sunsetDate) // RFC 8594
            w.Header().Set("Link", fmt.Sprintf(`</api/v2>; rel="successor-version"`))
            
            next.ServeHTTP(w, r)
        })
    }
}
```

### 4.3 Pagination Strategies

#### 4.3.1 Offset-Based Pagination

```go
// Request
GET /api/v1/cards?page=1&page_size=20

// Response
{
    "data": [...],
    "meta": {
        "page": 1,
        "page_size": 20,
        "total": 150,
        "total_pages": 8
    }
}
```

#### 4.3.2 Cursor-Based Pagination

```go
// Request
GET /api/v1/cards?cursor=eyJpZCI6MTIzLCJkdWUiOjEyMzQ1Njc4OTB9&limit=20

// Response
{
    "data": [...],
    "meta": {
        "cursor": "eyJpZCI6MTQzLCJkdWUiOjEyMzQ1Njc5MDB9",
        "has_more": true
    }
}
```

### 4.4 Error Handling (Padronizado)

**Exemplo: `pkg/errors/api_error.go`**

```go
package errors

import (
    "encoding/json"
    "net/http"
)

// APIError representa erro padronizado da API
type APIError struct {
    Error   string            `json:"error"`
    Message string            `json:"message"`
    Details map[string]string `json:"details,omitempty"`
    Code    string            `json:"code,omitempty"`
}

// RespondError escreve erro padronizado na resposta
func RespondError(w http.ResponseWriter, statusCode int, message string) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(statusCode)
    
    apiError := APIError{
        Error:   http.StatusText(statusCode),
        Message: message,
    }
    
    json.NewEncoder(w).Encode(apiError)
}

// RespondValidationError escreve erro de validação
func RespondValidationError(w http.ResponseWriter, details map[string]string) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusUnprocessableEntity)
    
    apiError := APIError{
        Error:   "Validation Error",
        Message: "Request validation failed",
        Details: details,
    }
    
    json.NewEncoder(w).Encode(apiError)
}
```

### 4.5 Rate Limiting Detalhado

**Exemplo: `app/api/http/middleware/rate_limiting_middleware.go`**

```go
package middleware

import (
    "net/http"
    "sync"
    "time"
    
    "github.com/redis/go-redis/v9"
)

// RateLimiter implementa rate limiting
type RateLimiter struct {
    redis  *redis.Client
    limits map[string]int // endpoint -> requests per minute
    mu     sync.RWMutex
}

func NewRateLimiter(redis *redis.Client) *RateLimiter {
    return &RateLimiter{
        redis: redis,
        limits: map[string]int{
            "/api/v1/auth/login":    5,  // 5 requests/minute
            "/api/v1/auth/register": 3,  // 3 requests/minute
            "default":                60, // 60 requests/minute
        },
    }
}

func (rl *RateLimiter) Middleware() func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            key := rl.getKey(r)
            limit := rl.getLimit(r.URL.Path)
            
            count, err := rl.redis.Incr(r.Context(), key).Result()
            if err != nil {
                // Se Redis falhar, permitir requisição (fail open)
                next.ServeHTTP(w, r)
                return
            }
            
            if count == 1 {
                // Primeira requisição - setar TTL
                rl.redis.Expire(r.Context(), key, time.Minute)
            }
            
            if count > int64(limit) {
                w.Header().Set("X-RateLimit-Limit", fmt.Sprintf("%d", limit))
                w.Header().Set("X-RateLimit-Remaining", "0")
                w.Header().Set("Retry-After", "60")
                http.Error(w, "Rate limit exceeded", http.StatusTooManyRequests)
                return
            }
            
            w.Header().Set("X-RateLimit-Limit", fmt.Sprintf("%d", limit))
            w.Header().Set("X-RateLimit-Remaining", fmt.Sprintf("%d", limit-int(count)))
            
            next.ServeHTTP(w, r)
        })
    }
}

func (rl *RateLimiter) getKey(r *http.Request) string {
    // Rate limit por IP ou por user ID
    userID := getUserIDFromContext(r.Context())
    if userID > 0 {
        return fmt.Sprintf("ratelimit:user:%d:%s", userID, r.URL.Path)
    }
    return fmt.Sprintf("ratelimit:ip:%s:%s", getClientIP(r), r.URL.Path)
}

func (rl *RateLimiter) getLimit(path string) int {
    rl.mu.RLock()
    defer rl.mu.RUnlock()
    
    if limit, ok := rl.limits[path]; ok {
        return limit
    }
    return rl.limits["default"]
}
```

### 4.6 CORS Configuration

**Exemplo: `app/api/http/middleware/cors_middleware.go`**

```go
package middleware

import "net/http"

func CORSMiddleware(allowedOrigins []string) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            origin := r.Header.Get("Origin")
            
            // Verificar se origin é permitida
            allowed := false
            for _, o := range allowedOrigins {
                if o == origin || o == "*" {
                    allowed = true
                    break
                }
            }
            
            if allowed {
                w.Header().Set("Access-Control-Allow-Origin", origin)
                w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
                w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
                w.Header().Set("Access-Control-Allow-Credentials", "true")
                w.Header().Set("Access-Control-Max-Age", "3600")
            }
            
            // Handle preflight
            if r.Method == "OPTIONS" {
                w.WriteHeader(http.StatusNoContent)
                return
            }
            
            next.ServeHTTP(w, r)
        })
    }
}
```

### 4.7 API Security Headers

**Exemplo: `app/api/http/middleware/security_headers_middleware.go`**

```go
package middleware

import "net/http"

func SecurityHeadersMiddleware() func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            // Security headers
            w.Header().Set("X-Content-Type-Options", "nosniff")
            w.Header().Set("X-Frame-Options", "DENY")
            w.Header().Set("X-XSS-Protection", "1; mode=block")
            w.Header().Set("Strict-Transport-Security", "max-age=31536000; includeSubDomains")
            w.Header().Set("Content-Security-Policy", "default-src 'self'")
            w.Header().Set("Referrer-Policy", "strict-origin-when-cross-origin")
            
            next.ServeHTTP(w, r)
        })
    }
}
```

### 4.8 API Documentation (Swagger/OpenAPI)

**Exemplo: Setup Swagger**

```go
//go:generate swag init -g cmd/api/main.go

import (
    "github.com/swaggo/http-swagger"
    _ "github.com/anki/docs" // Swagger docs
)

func setupSwagger(r *mux.Router) {
    r.PathPrefix("/swagger/").Handler(httpSwagger.WrapHandler)
}
```

## 5. Error Handling Strategy (Estratégia de Tratamento de Erros)

### 4.1 Hierarquia de Erros

**Princípio**: Erros fluem **INWARD → OUTWARD**, nunca o contrário!

```
┌─────────────────────────────────────────────────────────┐
│                    API LAYER                             │
│  • HTTP Status Codes (400, 404, 409, 500)               │
│  • Error Response DTOs                                   │
│  • Exception Middleware                                  │
└─────────────────────────┬───────────────────────────────┘
                          │ Catches & Maps
                          ↓
┌─────────────────────────────────────────────────────────┐
│                  SERVICE LAYER                          │
│  • Business Logic Validation                            │
│  • Domain Exception Translation                         │
│  • Logging                                              │
└─────────────────────────┬───────────────────────────────┘
                          │ Propagates
                          ↓
┌─────────────────────────────────────────────────────────┐
│                  DOMAIN LAYER                           │
│  • Domain Exceptions (pure business rules)              │
│  • Entity.validate()                                    │
│  • No infrastructure knowledge                          │
└─────────────────────────────────────────────────────────┘
```

### 4.2 Domain Exceptions (Erros de Domínio)

**Exemplo: `pkg/errors/domain_errors.go`**

```go
package errors

import "fmt"

// DomainError representa erro de regra de negócio
type DomainError struct {
    Code    string
    Message string
}

func (e *DomainError) Error() string {
    return fmt.Sprintf("%s: %s", e.Code, e.Message)
}

// Validation Errors (400 Bad Request)
type ValidationError struct {
    DomainError
    Field   string
    Value   interface{}
}

func NewValidationError(field, message string, value interface{}) *ValidationError {
    return &ValidationError{
        DomainError: DomainError{
            Code:    "VALIDATION_ERROR",
            Message: message,
        },
        Field: field,
        Value: value,
    }
}

// NotFound Errors (404 Not Found)
type NotFoundError struct {
    DomainError
    EntityType string
    EntityID   interface{}
}

func NewNotFoundError(entityType string, entityID interface{}) *NotFoundError {
    return &NotFoundError{
        DomainError: DomainError{
            Code:    "NOT_FOUND",
            Message: fmt.Sprintf("%s with ID %v not found", entityType, entityID),
        },
        EntityType: entityType,
        EntityID:   entityID,
    }
}

// Conflict Errors (409 Conflict)
type ConflictError struct {
    DomainError
    EntityType string
    Field      string
    Value      interface{}
}

func NewConflictError(entityType, field string, value interface{}) *ConflictError {
    return &ConflictError{
        DomainError: DomainError{
            Code:    "CONFLICT",
            Message: fmt.Sprintf("%s with %s='%v' already exists", entityType, field, value),
        },
        EntityType: entityType,
        Field:      field,
        Value:      value,
    }
}

// Authorization Errors (403 Forbidden)
type AuthorizationError struct {
    DomainError
    Action   string
    Resource string
}

func NewAuthorizationError(action, resource string) *AuthorizationError {
    return &AuthorizationError{
        DomainError: DomainError{
            Code:    "PERMISSION_DENIED",
            Message: fmt.Sprintf("Permission denied for action: %s on resource: %s", action, resource),
        },
        Action:   action,
        Resource: resource,
    }
}

// Authentication Errors (401 Unauthorized)
type AuthenticationError struct {
    DomainError
}

func NewAuthenticationError(message string) *AuthenticationError {
    return &AuthenticationError{
        DomainError: DomainError{
            Code:    "AUTHENTICATION_ERROR",
            Message: message,
        },
    }
}

// Business Rule Errors (422 Unprocessable Entity)
type BusinessRuleError struct {
    DomainError
    Rule string
}

func NewBusinessRuleError(rule, message string) *BusinessRuleError {
    return &BusinessRuleError{
        DomainError: DomainError{
            Code:    "BUSINESS_RULE_VIOLATION",
            Message: message,
        },
        Rule: rule,
    }
}
```

### 4.3 Error Mapping no Handler

**Exemplo: `app/api/http/middleware/error_middleware.go`**

```go
package middleware

import (
    "encoding/json"
    "log"
    "net/http"
    
    "github.com/anki/pkg/errors"
)

// ErrorResponse representa resposta de erro padronizada
type ErrorResponse struct {
    Error ErrorDetail `json:"error"`
}

type ErrorDetail struct {
    Code    string `json:"code"`
    Message string `json:"message"`
}

// ErrorMiddleware mapeia erros de domínio para HTTP status codes
func ErrorMiddleware() func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            defer func() {
                if err := recover(); err != nil {
                    log.Printf("Panic recovered: %v", err)
                    respondError(w, http.StatusInternalServerError, "INTERNAL_ERROR", "Internal server error")
                }
            }()
            
            next.ServeHTTP(w, r)
        })
    }
}

// HandleError trata erro e retorna resposta HTTP apropriada
func HandleError(w http.ResponseWriter, err error) {
    switch e := err.(type) {
    case *errors.ValidationError:
        respondError(w, http.StatusBadRequest, e.Code, e.Message)
    case *errors.NotFoundError:
        respondError(w, http.StatusNotFound, e.Code, e.Message)
    case *errors.ConflictError:
        respondError(w, http.StatusConflict, e.Code, e.Message)
    case *errors.AuthorizationError:
        respondError(w, http.StatusForbidden, e.Code, e.Message)
    case *errors.AuthenticationError:
        respondError(w, http.StatusUnauthorized, e.Code, e.Message)
    case *errors.BusinessRuleError:
        respondError(w, http.StatusUnprocessableEntity, e.Code, e.Message)
    default:
        log.Printf("Unhandled error: %v", err)
        respondError(w, http.StatusInternalServerError, "INTERNAL_ERROR", "Internal server error")
    }
}

func respondError(w http.ResponseWriter, statusCode int, code, message string) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(statusCode)
    
    response := ErrorResponse{
        Error: ErrorDetail{
            Code:    code,
            Message: message,
        },
    }
    
    json.NewEncoder(w).Encode(response)
}
```

### 4.4 Uso no Service

**Exemplo: `core/services/services/deck_service.go`**

```go
func (s *DeckService) CreateDeck(ctx context.Context, deck *entities.Deck) (*entities.Deck, error) {
    // Validação de negócio
    if deck.Name == "" {
        return nil, errors.NewValidationError("name", "Deck name is required", nil)
    }
    
    // Verificar duplicata
    existing, err := s.repo.FindByName(ctx, deck.Name)
    if err != nil {
        return nil, err
    }
    if existing != nil {
        return nil, errors.NewConflictError("Deck", "name", deck.Name)
    }
    
    // Salvar
    saved, err := s.repo.Save(ctx, deck)
    if err != nil {
        return nil, err
    }
    
    return saved, nil
}

func (s *DeckService) GetDeck(ctx context.Context, id int64) (*entities.Deck, error) {
    deck, err := s.repo.FindByID(ctx, id)
    if err != nil {
        return nil, err
    }
    if deck == nil {
        return nil, errors.NewNotFoundError("Deck", id)
    }
    
    return deck, nil
}
```

### 4.5 Uso no Handler

**Exemplo: `app/api/http/handlers/deck_handler.go`**

```go
func (h *DeckHandler) CreateDeck(w http.ResponseWriter, r *http.Request) {
    var req CreateDeckRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        middleware.HandleError(w, errors.NewValidationError("body", "Invalid request body", nil))
        return
    }
    
    deck := &entities.Deck{
        Name:   req.Name,
        UserID: req.UserID,
    }
    
    saved, err := h.service.CreateDeck(r.Context(), deck)
    if err != nil {
        middleware.HandleError(w, err) // Mapeia automaticamente para HTTP status
        return
    }
    
    response := toDeckResponse(saved)
    json.NewEncoder(w).Encode(response)
}
```

## 5. Princípios SOLID Aplicados

**SOLID** é um acrônimo para cinco princípios de design orientado a objetos que tornam o software mais manutenível, flexível e escalável.

Criados por **Robert C. Martin** (Uncle Bob), esses princípios são a base do código limpo e profissional.

---

### 5.1 Single Responsibility Principle (SRP)

**Definição**: 
> **"Uma classe/struct deve ter uma, e apenas uma, razão para mudar."**

Uma classe deve fazer **uma coisa** e fazer bem. Se uma classe tem múltiplas responsabilidades, mudanças em uma responsabilidade podem afetar outras.

#### Por Que Importa
- ✅ **Mais fácil de entender** - Classe tem propósito claro
- ✅ **Mais fácil de testar** - Testa um comportamento por vez
- ✅ **Mais fácil de manter** - Mudanças são isoladas
- ✅ **Menor acoplamento** - Dependências são mínimas

#### ❌ Bad Example (Múltiplas Responsabilidades)

```go
// BAD: Card tem MUITAS responsabilidades
type Card struct {
    ID     int64
    NoteID int64
    Due    int64
    State  string
}

// Responsabilidade 1: Business logic
func (c *Card) IsDue(now int64) bool {
    return c.Due <= now && !c.Suspended && !c.Buried
}

// Responsabilidade 2: Database operations (BAD!)
func (c *Card) Save(db *sql.DB) error {
    // Acesso direto ao banco no domain model - BAD!
    _, err := db.Exec("INSERT INTO cards (id, note_id, due, state) VALUES ($1, $2, $3, $4)",
        c.ID, c.NoteID, c.Due, c.State)
    return err
}

// Responsabilidade 3: Email sending (BAD!)
func (c *Card) SendNotification() error {
    // Lógica de email no domain model - BAD!
    return sendEmail(c.UserID, "Card is due!")
}

// Responsabilidade 4: Password hashing (BAD!)
func (c *Card) HashPassword(password string) (string, error) {
    // Crypto no domain model - BAD!
    return bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
}

// Responsabilidade 5: Logging (BAD!)
func (c *Card) LogCreation() {
    // Logging no domain model - BAD!
    log.Printf("Card %d created", c.ID)
}
```

**Problemas**:
- Mudanças no schema do banco afetam Card
- Mudanças no serviço de email afetam Card
- Mudanças no logging afetam Card
- Difícil testar (precisa de banco real, servidor de email, etc.)
- Viola separation of concerns

#### ✅ Good Example (Responsabilidade Única)

```go
// ===== Domain Layer =====
// internal/domain/entities/card.go
type Card struct {
    ID       int64
    NoteID   int64
    Due      int64
    State    valueobjects.CardState
    Suspended bool
    Buried    bool
}

// GOOD: Apenas business logic e validação
// Single Responsibility: Representar um card com regras de negócio
func (c *Card) IsDue(now int64) bool {
    // Pure business logic
    if c.Suspended || c.Buried {
        return false
    }
    return c.Due <= now
}

func (c *Card) Validate() error {
    // Business validation only
    if c.NoteID == 0 {
        return errors.New("card must have a note")
    }
    return nil
}

// ===== Service Layer =====
// internal/application/services/card_service.go
type CardService struct {
    repo         secondary.ICardRepository
    emailService EmailService
    hasher       PasswordHasher
}

// Single Responsibility: Orquestrar operações de card
func NewCardService(
    repo secondary.ICardRepository,
    emailService EmailService,
    hasher PasswordHasher,
) *CardService {
    return &CardService{
        repo:         repo,
        emailService: emailService,
        hasher:       hasher,
    }
}

func (s *CardService) ReviewCard(ctx context.Context, cardID int64, rating int) error {
    // Orquestra: busca card, valida, salva
    card, err := s.repo.FindByID(ctx, cardID)
    if err != nil {
        return err
    }
    
    // Business logic
    if !card.IsDue(time.Now().Unix()) {
        return errors.New("card is not due")
    }
    
    // Calcula novo intervalo (delegado para scheduler)
    // ... scheduling logic ...
    
    // Salva (delegado para repository)
    return s.repo.Save(ctx, card)
}

// ===== Repository Layer =====
// internal/infrastructure/persistence/postgres/card_repository.go
type PostgresCardRepository struct {
    db *sql.DB
}

// Single Responsibility: Persistência de dados
func (r *PostgresCardRepository) Save(ctx context.Context, card *entities.Card) error {
    // Database logic only
    _, err := r.db.ExecContext(ctx,
        "INSERT INTO cards (id, note_id, due, state) VALUES ($1, $2, $3, $4)",
        card.ID, card.NoteID, card.Due, card.State)
    return err
}

// ===== Email Service =====
// internal/infrastructure/external/email_service.go
type EmailService struct {
    smtpClient *smtp.Client
}

// Single Responsibility: Envio de emails
func (s *EmailService) SendCardDueNotification(userID int64, cardID int64) error {
    // Email logic only
    // ...
    return nil
}

// ===== Password Hasher =====
// pkg/security/password.go
type PasswordHasher struct{}

// Single Responsibility: Hash de senhas
func (h *PasswordHasher) Hash(password string) (string, error) {
    return bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
}
```

**Benefícios**:
- Cada struct tem UMA razão para mudar
- Fácil testar (mock dependencies)
- Separação clara de responsabilidades
- Mudanças são isoladas

### 5.2 Open/Closed Principle (OCP)

**Definição**: 
> **"Entidades de software devem ser abertas para extensão, mas fechadas para modificação."**

Você deve ser capaz de **adicionar nova funcionalidade** sem alterar código existente.

#### Por Que Importa
- ✅ **Previne breaking changes** - Não modifica código que funciona
- ✅ **Promove extensibilidade** - Adiciona features via novas classes
- ✅ **Reduz risco** - Menos chance de introduzir bugs
- ✅ **Habilita plugins** - Extensões de terceiros

#### ❌ Bad Example (Modificação Necessária)

```go
// BAD: Deve modificar esta struct para adicionar novos schedulers
type StudyService struct {
    scheduler string // "sm2" ou "fsrs"
}

func (s *StudyService) CalculateInterval(card *entities.Card, rating int) (*SchedulingResult, error) {
    switch s.scheduler {
    case "sm2":
        // SM-2 algorithm
        return calculateSM2Interval(card, rating)
    case "fsrs":
        // FSRS algorithm
        return calculateFSRSInterval(card, rating)
    case "new_algorithm": // NOVO - teve que modificar código existente!
        // New algorithm
        return calculateNewAlgorithmInterval(card, rating)
    default:
        return nil, errors.New("unknown scheduler")
    }
    // Adicionar novo scheduler = modificar esta struct = violação de OCP
}
```

**Problema**: Todo novo algoritmo de scheduling requer modificar `StudyService`.

#### ✅ Good Example (Extensão via Interface)

```go
// ===== Interface (Aberto para Extensão) =====
// internal/domain/services/scheduler.go
type SchedulerService interface {
    CalculateInterval(
        card *entities.Card,
        rating int,
        options *valueobjects.DeckOptions,
    ) (*SchedulingResult, error)
}

// ===== Implementações Concretas (Fechado para Modificação) =====
// internal/domain/services/sm2_scheduler.go
type SM2Scheduler struct{}

func NewSM2Scheduler() *SM2Scheduler {
    return &SM2Scheduler{}
}

func (s *SM2Scheduler) CalculateInterval(
    card *entities.Card,
    rating int,
    options *valueobjects.DeckOptions,
) (*SchedulingResult, error) {
    // SM-2 algorithm logic
    // ...
    return &SchedulingResult{
        Interval: calculateSM2Interval(card, rating, options),
        EaseFactor: card.EaseFactor,
    }, nil
}

// internal/domain/services/fsrs_scheduler.go
type FSRSScheduler struct{}

func NewFSRSScheduler() *FSRSScheduler {
    return &FSRSScheduler{}
}

func (s *FSRSScheduler) CalculateInterval(
    card *entities.Card,
    rating int,
    options *valueobjects.DeckOptions,
) (*SchedulingResult, error) {
    // FSRS algorithm logic
    // ...
    return &SchedulingResult{
        Interval: calculateFSRSInterval(card, rating, options),
        EaseFactor: card.EaseFactor,
    }, nil
}

// NOVO: Adicionar sem modificar código existente!
// internal/domain/services/new_algorithm_scheduler.go
type NewAlgorithmScheduler struct{}

func NewNewAlgorithmScheduler() *NewAlgorithmScheduler {
    return &NewAlgorithmScheduler{}
}

func (s *NewAlgorithmScheduler) CalculateInterval(
    card *entities.Card,
    rating int,
    options *valueobjects.DeckOptions,
) (*SchedulingResult, error) {
    // New algorithm logic
    // ...
    return &SchedulingResult{
        Interval: calculateNewAlgorithmInterval(card, rating, options),
        EaseFactor: card.EaseFactor,
    }, nil
}

// ===== Service (Nunca precisa modificação) =====
// internal/application/services/study_service.go
type StudyService struct {
    scheduler SchedulerService // Interface, não implementação concreta!
}

func NewStudyService(scheduler SchedulerService) *StudyService {
    return &StudyService{scheduler: scheduler}
}

func (s *StudyService) ReviewCard(ctx context.Context, cardID int64, rating int) error {
    card, err := s.cardRepo.FindByID(ctx, cardID)
    if err != nil {
        return err
    }
    
    // Usa interface - não conhece implementação específica
    result, err := s.scheduler.CalculateInterval(card, rating, card.Deck.Options)
    if err != nil {
        return err
    }
    
    // Atualiza card com resultado
    card.Interval = result.Interval
    card.Due = time.Now().Unix() + result.Interval
    
    return s.cardRepo.Save(ctx, card)
}

// ===== Uso =====
// Production: Usa SM-2
service := NewStudyService(NewSM2Scheduler())

// Production: Usa FSRS
service := NewStudyService(NewFSRSScheduler())

// NOVO: Adicionar novo algoritmo - SEM modificar StudyService!
service := NewStudyService(NewNewAlgorithmScheduler())
```

**Benefícios**:
- `StudyService` nunca precisa ser modificado
- Fácil adicionar novos algoritmos
- Código existente permanece estável
- Testável (pode injetar mock scheduler)

#### Exemplo Real do Projeto: Repository Pattern

```go
// Interface (FECHADO para modificação)
type CardRepository interface {
    FindByID(ctx context.Context, id int64) (*entities.Card, error)
    Save(ctx context.Context, card *entities.Card) error
}

// EXTENDER com novas implementações (ABERTO para extensão)
type PostgresCardRepository struct {
    db *sql.DB
}

func (r *PostgresCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // PostgreSQL implementation
}

type MongoCardRepository struct { // NOVO - sem modificação!
    client *mongo.Client
}

func (r *MongoCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // MongoDB implementation
}

type RedisCardRepository struct { // NOVO - sem modificação!
    client *redis.Client
}

func (r *RedisCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // Redis implementation
}
```

### 5.3 Liskov Substitution Principle (LSP)

**Definição**: 
> **"Objetos de uma superclasse devem ser substituíveis por objetos de uma subclasse sem quebrar a aplicação."**

Subtipos devem ser **substituíveis** por seus tipos base.

#### Por Que Importa
- ✅ **Polimorfismo funciona** - Promessas da interface são mantidas
- ✅ **Sem surpresas** - Subclasses se comportam como esperado
- ✅ **Contrato respeitado** - Honra o contrato da interface
- ✅ **Substituição segura** - Troca implementações sem bugs

#### ❌ Bad Example (Violação de LSP)

```go
// Interface define contrato
type CardRepository interface {
    FindByID(ctx context.Context, id int64) (*entities.Card, error)
    // Contrato: Retorna Card se encontrado, nil se não encontrado
    // NUNCA deve lançar NotFoundError!
}

// PostgreSQL - LSP compliant
type PostgresCardRepository struct {
    db *sql.DB
}

func (r *PostgresCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // Honra contrato: Retorna Card ou nil
    var card entities.Card
    err := r.db.QueryRowContext(ctx, "SELECT * FROM cards WHERE id = $1", id).Scan(&card)
    if err == sql.ErrNoRows {
        return nil, nil // OK: Retorna nil quando não encontrado
    }
    if err != nil {
        return nil, err
    }
    return &card, nil
}

// Redis - LSP compliant
type RedisCardRepository struct {
    client *redis.Client
}

func (r *RedisCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // Honra contrato: Retorna Card ou nil
    data, err := r.client.Get(ctx, fmt.Sprintf("card:%d", id)).Result()
    if err == redis.Nil {
        return nil, nil // OK: Retorna nil quando não encontrado
    }
    if err != nil {
        return nil, err
    }
    // Deserialize e retorna
    return deserializeCard(data), nil
}

// BAD: Violação de LSP
type BadCardRepository struct {
    db *sql.DB
}

func (r *BadCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // Viola contrato: Lança exceção em vez de retornar nil
    var card entities.Card
    err := r.db.QueryRowContext(ctx, "SELECT * FROM cards WHERE id = $1", id).Scan(&card)
    if err == sql.ErrNoRows {
        return nil, errors.New("card not found") // LSP VIOLATION!
        // Deveria retornar (nil, nil), não lançar erro
    }
    return &card, nil
}

// Uso
func getCard(repo CardRepository, id int64) (*entities.Card, error) {
    card, err := repo.FindByID(ctx, id)
    if err != nil {
        return nil, err // Espera que err seja nil quando card não existe
    }
    return card, nil
}

// Funciona com PostgresCardRepository
getCard(&PostgresCardRepository{db}, 123) // OK

// Funciona com RedisCardRepository
getCard(&RedisCardRepository{client}, 123) // OK

// QUEBRA com BadCardRepository - LSP violado!
getCard(&BadCardRepository{db}, 999) // CRASH! Erro inesperado
```

#### ✅ Good Example (LSP Compliant)

```go
// Interface define contrato claramente
type CardRepository interface {
    // Contrato: Retorna (Card, nil) se encontrado
    //           Retorna (nil, nil) se não encontrado
    //           Retorna (nil, error) apenas para erros de sistema
    FindByID(ctx context.Context, id int64) (*entities.Card, error)
}

// PostgreSQL - LSP compliant
type PostgresCardRepository struct {
    db *sql.DB
}

func (r *PostgresCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // Honra contrato: Retorna Card ou nil
    var card entities.Card
    err := r.db.QueryRowContext(ctx, "SELECT * FROM cards WHERE id = $1", id).Scan(&card)
    if err == sql.ErrNoRows {
        return nil, nil // OK: Retorna nil quando não encontrado
    }
    if err != nil {
        return nil, err // Erro de sistema
    }
    return &card, nil
}

// Redis - LSP compliant
type RedisCardRepository struct {
    client *redis.Client
}

func (r *RedisCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // Honra contrato: Retorna Card ou nil
    data, err := r.client.Get(ctx, fmt.Sprintf("card:%d", id)).Result()
    if err == redis.Nil {
        return nil, nil // OK: Retorna nil quando não encontrado
    }
    if err != nil {
        return nil, err // Erro de sistema
    }
    return deserializeCard(data), nil
}

// In-Memory (para testes) - LSP compliant
type InMemoryCardRepository struct {
    cards map[int64]*entities.Card
}

func (r *InMemoryCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // Honra contrato: Retorna Card ou nil
    card, exists := r.cards[id]
    if !exists {
        return nil, nil // OK: Retorna nil quando não encontrado
    }
    return card, nil
}

// Uso: Qualquer implementação pode substituir a interface
func processCard(repo CardRepository, id int64) error {
    card, err := repo.FindByID(ctx, id)
    if err != nil {
        return err // Erro de sistema
    }
    if card == nil {
        return errors.New("card not found") // Tratamento consistente
    }
    // Processa card...
    return nil
}

// Todas as implementações são substituíveis!
processCard(&PostgresCardRepository{db}, 123)     // OK
processCard(&RedisCardRepository{client}, 123)     // OK
processCard(&InMemoryCardRepository{cards}, 123)   // OK (testes)
```

#### Exemplo Real do Projeto: Repository Pattern

```go
// Interface define contrato
type CardRepository interface {
    // Contrato: Retorna Entity se encontrado, nil se não encontrado
    // NUNCA lança NotFoundError!
    FindByID(ctx context.Context, id int64) (*entities.Card, error)
}

// PostgreSQL implementation - LSP compliant
type PostgresCardRepository struct {
    db *sql.DB
}

func (r *PostgresCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // Honra contrato: Retorna Card ou nil
    var dbModel models.CardModel
    err := r.db.QueryRowContext(ctx,
        "SELECT id, note_id, due, state FROM cards WHERE id = $1", id,
    ).Scan(&dbModel.ID, &dbModel.NoteID, &dbModel.Due, &dbModel.State)
    
    if err == sql.ErrNoRows {
        return nil, nil // OK: Retorna nil quando não encontrado
    }
    if err != nil {
        return nil, err
    }
    
    return mappers.ToDomain(&dbModel), nil
}

// Redis implementation - LSP compliant
type RedisCardRepository struct {
    client *redis.Client
}

func (r *RedisCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // Honra contrato: Retorna Card ou nil
    data, err := r.client.Get(ctx, fmt.Sprintf("card:%d", id)).Result()
    if err == redis.Nil {
        return nil, nil // OK: Retorna nil quando não encontrado
    }
    if err != nil {
        return nil, err
    }
    
    var card entities.Card
    if err := json.Unmarshal([]byte(data), &card); err != nil {
        return nil, err
    }
    return &card, nil
}
```

### 5.4 Interface Segregation Principle (ISP)

**Definição**: 
> **"Clientes não devem ser forçados a depender de interfaces que não usam."**

Crie **interfaces focadas e específicas** em vez de uma interface grande e genérica.

#### Por Que Importa
- ✅ **Dependências mínimas** - Depende apenas do que precisa
- ✅ **Implementação mais fácil** - Implementa apenas métodos relevantes
- ✅ **Melhor coesão** - Métodos relacionados agrupados
- ✅ **Evolução flexível** - Muda uma interface sem afetar outras

#### ❌ Bad Example (Fat Interface)

```go
// BAD: Interface gorda forçando todos os repositórios a implementar todos os métodos
type CardRepository interface {
    // Operações de leitura
    FindAll(ctx context.Context) ([]*entities.Card, error)
    FindByID(ctx context.Context, id int64) (*entities.Card, error)
    FindByDeckID(ctx context.Context, deckID int64) ([]*entities.Card, error)
    
    // Operações de escrita
    Save(ctx context.Context, card *entities.Card) error
    Delete(ctx context.Context, id int64) error
    
    // Operações de email (BAD! Não é responsabilidade do repository)
    SendEmail(ctx context.Context, card *entities.Card) error // BAD!
    
    // Operações de relatório (BAD! Não é responsabilidade do repository)
    GenerateReport(ctx context.Context) ([]byte, error) // BAD!
    
    // Operações de cache (BAD! Não é responsabilidade do repository)
    InvalidateCache(ctx context.Context, id int64) error // BAD!
}

// Read-only repository (para relatórios) - forçado a implementar métodos desnecessários!
type ReadOnlyCardRepository struct{}

func (r *ReadOnlyCardRepository) FindAll(ctx context.Context) ([]*entities.Card, error) {
    // OK: precisa disso
}

func (r *ReadOnlyCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // OK: precisa disso
}

func (r *ReadOnlyCardRepository) Save(ctx context.Context, card *entities.Card) error {
    return errors.New("read-only repository cannot save") // Forçado a implementar!
}

func (r *ReadOnlyCardRepository) Delete(ctx context.Context, id int64) error {
    return errors.New("read-only repository cannot delete") // Forçado a implementar!
}

func (r *ReadOnlyCardRepository) SendEmail(ctx context.Context, card *entities.Card) error {
    return errors.New("repository cannot send email") // Forçado a implementar!
}

func (r *ReadOnlyCardRepository) GenerateReport(ctx context.Context) ([]byte, error) {
    return nil, errors.New("repository cannot generate report") // Forçado a implementar!
}

func (r *ReadOnlyCardRepository) InvalidateCache(ctx context.Context, id int64) error {
    return errors.New("repository cannot invalidate cache") // Forçado a implementar!
}
```

**Problema**: `ReadOnlyCardRepository` é forçado a implementar `Save()`, `Delete()`, `SendEmail()`, etc., mesmo que não precise deles.

#### ✅ Good Example (Segregated Interfaces)

```go
// GOOD: Interfaces segregadas e focadas

// ===== Read operations only =====
type CardReadRepository interface {
    FindAll(ctx context.Context, filter *filters.CardFilter) ([]*entities.Card, error)
    FindByID(ctx context.Context, id int64) (*entities.Card, error)
    FindByDeckID(ctx context.Context, deckID int64) ([]*entities.Card, error)
    Count(ctx context.Context, filter *filters.CardFilter) (int64, error)
}

// ===== Write operations only =====
type CardWriteRepository interface {
    Save(ctx context.Context, card *entities.Card) error
    Delete(ctx context.Context, id int64) error
    BatchSave(ctx context.Context, cards []*entities.Card) error
}

// ===== Full repository (combina ambas) =====
type CardRepository interface {
    CardReadRepository
    CardWriteRepository
}

// ===== Implementações =====

// Read-only repository (para relatórios) - só implementa o que precisa!
type ReadOnlyCardRepository struct {
    db *sql.DB
}

func (r *ReadOnlyCardRepository) FindAll(ctx context.Context, filter *filters.CardFilter) ([]*entities.Card, error) {
    // Implementação...
}

func (r *ReadOnlyCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // Implementação...
}

func (r *ReadOnlyCardRepository) FindByDeckID(ctx context.Context, deckID int64) ([]*entities.Card, error) {
    // Implementação...
}

func (r *ReadOnlyCardRepository) Count(ctx context.Context, filter *filters.CardFilter) (int64, error) {
    // Implementação...
}

// Full repository (CRUD completo)
type PostgresCardRepository struct {
    db *sql.DB
}

// Implementa CardReadRepository
func (r *PostgresCardRepository) FindAll(ctx context.Context, filter *filters.CardFilter) ([]*entities.Card, error) {
    // Implementação...
}

func (r *PostgresCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // Implementação...
}

// Implementa CardWriteRepository
func (r *PostgresCardRepository) Save(ctx context.Context, card *entities.Card) error {
    // Implementação...
}

func (r *PostgresCardRepository) Delete(ctx context.Context, id int64) error {
    // Implementação...
}

// ===== Uso =====

// Read-only service (não precisa de write methods)
type ReportService struct {
    readRepo CardReadRepository // Depende apenas do que precisa!
}

func (s *ReportService) GenerateDeckReport(ctx context.Context, deckID int64) (*Report, error) {
    cards, err := s.readRepo.FindByDeckID(ctx, deckID)
    if err != nil {
        return nil, err
    }
    // Gera relatório...
    return report, nil
}

// Full service (precisa de read e write)
type CardService struct {
    repo CardRepository // Depende de interface completa
}

func (s *CardService) CreateCard(ctx context.Context, card *entities.Card) error {
    return s.repo.Save(ctx, card) // Usa write method
}

func (s *CardService) GetCard(ctx context.Context, id int64) (*entities.Card, error) {
    return s.repo.FindByID(ctx, id) // Usa read method
}
```

**Benefícios**:
- `ReportService` depende apenas de `CardReadRepository` (não precisa de write methods)
- `ReadOnlyCardRepository` implementa apenas o que precisa
- Interfaces focadas e específicas
- Fácil evoluir interfaces independentemente

#### Exemplo Real do Projeto: Service Interfaces

```go
// ===== Interfaces Segregadas (GOOD) =====

// Read operations only
type CardReadService interface {
    FindByID(ctx context.Context, id int64) (*entities.Card, error)
    ListAll(ctx context.Context, filter *filters.CardFilter) ([]*entities.Card, error)
    Count(ctx context.Context, filter *filters.CardFilter) (int64, error)
}

// Write operations only
type CardWriteService interface {
    Create(ctx context.Context, card *entities.Card) error
    Update(ctx context.Context, card *entities.Card) error
    Delete(ctx context.Context, id int64) error
}

// Read-only service (relatórios, analytics)
type ReportService struct {
    readService CardReadService // Não precisa de write methods!
}

func (s *ReportService) GenerateReport(ctx context.Context) (*Report, error) {
    cards, err := s.readService.ListAll(ctx, nil)
    // ...
}

// Full service (CRUD operations)
type CardService struct {
    readRepo  CardReadRepository
    writeRepo CardWriteRepository
}

// Implementa ambas interfaces
func (s *CardService) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    return s.readRepo.FindByID(ctx, id)
}

func (s *CardService) Create(ctx context.Context, card *entities.Card) error {
    return s.writeRepo.Save(ctx, card)
}
```

### 5.5 Dependency Inversion Principle (DIP)

**Definição**: 
> **"Módulos de alto nível não devem depender de módulos de baixo nível. Ambos devem depender de abstrações."**
> 
> **"Abstrações não devem depender de detalhes. Detalhes devem depender de abstrações."**

Dependa de **interfaces/abstrações**, não de **implementações concretas**.

#### Por Que Importa
- ✅ **Acoplamento fraco** - Fácil trocar implementações
- ✅ **Testabilidade** - Fácil mockar dependências
- ✅ **Flexibilidade** - Muda implementação sem mudar consumidores
- ✅ **Reutilização** - Lógica de alto nível pode usar diferentes implementações de baixo nível

#### ❌ Bad Example (Dependência Direta)

```go
// Low-level module (concreto)
type PostgresDatabase struct {
    db *sql.DB
}

func (d *PostgresDatabase) SaveCard(card *entities.Card) error {
    // PostgreSQL specific code
    _, err := d.db.Exec("INSERT INTO cards ...")
    return err
}

// High-level module (depende de concreto)
type CardService struct {
    // BAD: Depende diretamente de PostgreSQL
    db *PostgresDatabase // Dependência direta em classe concreta!
}

func NewCardService() *CardService {
    db, _ := sql.Open("postgres", "...")
    return &CardService{
        db: &PostgresDatabase{db: db}, // Cria dependência internamente - BAD!
    }
}

func (s *CardService) CreateCard(ctx context.Context, card *entities.Card) error {
    // Tightly coupled to PostgreSQL
    return s.db.SaveCard(card)
}

// Problema: Não pode trocar para MongoDB sem modificar CardService
// Problema: Não pode testar CardService sem PostgreSQL real
```

#### ✅ Good Example (Dependency Inversion)

```go
// ===== Abstração (Interface) =====
// internal/domain/repositories/card_repository.go
type CardRepository interface {
    // HIGH-LEVEL abstraction
    // Define O QUE precisamos, não COMO
    FindByID(ctx context.Context, id int64) (*entities.Card, error)
    Save(ctx context.Context, card *entities.Card) error
}

// ===== High-level module depende de abstração =====
// internal/application/services/card_service.go
type CardService struct {
    // GOOD: Depende de abstração (interface)
    repo CardRepository // Interface, não implementação concreta!
}

func NewCardService(repo CardRepository) *CardService {
    return &CardService{repo: repo} // Dependency Injection
}

func (s *CardService) CreateCard(ctx context.Context, card *entities.Card) error {
    // Não conhece implementação específica
    card.Validate() // Business logic
    return s.repo.Save(ctx, card) // Usa interface
}

// ===== Low-level modules implementam abstração =====
// internal/infrastructure/persistence/postgres/card_repository.go
type PostgresCardRepository struct {
    db *sql.DB
}

func NewPostgresCardRepository(db *sql.DB) CardRepository {
    return &PostgresCardRepository{db: db}
}

func (r *PostgresCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // PostgreSQL specific code
    var card entities.Card
    err := r.db.QueryRowContext(ctx, "SELECT * FROM cards WHERE id = $1", id).Scan(&card)
    if err == sql.ErrNoRows {
        return nil, nil
    }
    return &card, err
}

func (r *PostgresCardRepository) Save(ctx context.Context, card *entities.Card) error {
    // PostgreSQL specific code
    _, err := r.db.ExecContext(ctx, "INSERT INTO cards ...", card.ID, card.NoteID)
    return err
}

// internal/infrastructure/persistence/mongo/card_repository.go
type MongoCardRepository struct {
    client *mongo.Client
}

func NewMongoCardRepository(client *mongo.Client) CardRepository {
    return &MongoCardRepository{client: client}
}

func (r *MongoCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // MongoDB specific code
    collection := r.client.Database("anki").Collection("cards")
    var card entities.Card
    err := collection.FindOne(ctx, bson.M{"_id": id}).Decode(&card)
    if err == mongo.ErrNoDocuments {
        return nil, nil
    }
    return &card, err
}

func (r *MongoCardRepository) Save(ctx context.Context, card *entities.Card) error {
    // MongoDB specific code
    collection := r.client.Database("anki").Collection("cards")
    _, err := collection.InsertOne(ctx, card)
    return err
}

// internal/infrastructure/persistence/inmemory/card_repository.go
type InMemoryCardRepository struct {
    cards map[int64]*entities.Card
    mu    sync.RWMutex
}

func NewInMemoryCardRepository() CardRepository {
    return &InMemoryCardRepository{
        cards: make(map[int64]*entities.Card),
    }
}

func (r *InMemoryCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // In-memory storage (para testes)
    r.mu.RLock()
    defer r.mu.RUnlock()
    card, exists := r.cards[id]
    if !exists {
        return nil, nil
    }
    return card, nil
}

func (r *InMemoryCardRepository) Save(ctx context.Context, card *entities.Card) error {
    // In-memory storage
    r.mu.Lock()
    defer r.mu.Unlock()
    r.cards[card.ID] = card
    return nil
}

// ===== Dependency Injection =====
// Production: Usa PostgreSQL
db, _ := sql.Open("postgres", databaseURL)
service := NewCardService(NewPostgresCardRepository(db))

// Testing: Usa in-memory
service := NewCardService(NewInMemoryCardRepository())

// Switch to MongoDB: SEM mudanças em CardService!
client, _ := mongo.Connect(ctx, mongoURI)
service := NewCardService(NewMongoCardRepository(client))
```

**Benefícios**:
- `CardService` não conhece PostgreSQL, MongoDB ou in-memory
- Fácil trocar implementações
- Fácil testar (injeta mock repository)
- Lógica de alto nível estável, detalhes de baixo nível flexíveis

---

### 5.6 SOLID em Prática (Exemplo Real do Projeto)

Vamos ver como **todos os 5 princípios SOLID** funcionam juntos no projeto:

```go
// ===== Domain Layer =====
// internal/domain/entities/card.go
type Card struct {
    // SRP: Apenas business logic
    // Sem database, sem HTTP, sem email
    ID       int64
    NoteID   int64
    Due      int64
    State    valueobjects.CardState
}

func (c *Card) Validate() error {
    // Business validation only
    if c.NoteID == 0 {
        return errors.New("card must have a note")
    }
    return nil
}

// ===== Interfaces =====
// internal/domain/repositories/card_repository.go
type CardRepository interface {
    // ISP: Interface focada (apenas operações de dados)
    // OCP: Aberto para extensão (novas implementações)
    FindByID(ctx context.Context, id int64) (*entities.Card, error)
    Save(ctx context.Context, card *entities.Card) error
}

// internal/application/interfaces/card_service.go
type CardService interface {
    // ISP: Interface focada (apenas operações de negócio)
    // OCP: Aberto para extensão
    Create(ctx context.Context, card *entities.Card) error
    Get(ctx context.Context, id int64) (*entities.Card, error)
}

// ===== Service (High-level) =====
// internal/application/services/card_service.go
type cardService struct {
    // SRP: Apenas orquestração de negócio
    // DIP: Depende de abstração (CardRepository)
    // LSP: Pode ser substituído por qualquer implementação de CardService
    repo CardRepository // DIP: Depende de abstração
}

func NewCardService(repo CardRepository) CardService { // DIP: Injeta dependência
    return &cardService{repo: repo}
}

func (s *cardService) Create(ctx context.Context, card *entities.Card) error {
    card.Validate() // Business logic
    return s.repo.Save(ctx, card) // Delegado para repository
}

// ===== Repository (Low-level) =====
// internal/infrastructure/persistence/postgres/card_repository.go
type PostgresCardRepository struct {
    // SRP: Apenas operações de banco de dados
    // LSP: Totalmente substituível por CardRepository
    // OCP: Estende CardRepository sem modificação
    db *sql.DB
}

func NewPostgresCardRepository(db *sql.DB) CardRepository {
    return &PostgresCardRepository{db: db}
}

func (r *PostgresCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // PostgreSQL specific code
    // ...
}

func (r *PostgresCardRepository) Save(ctx context.Context, card *entities.Card) error {
    // PostgreSQL specific code
    // ...
}

// internal/infrastructure/persistence/mongo/card_repository.go
type MongoCardRepository struct {
    // OCP: Nova implementação sem modificar código existente
    // LSP: Totalmente substituível por CardRepository
    client *mongo.Client
}

func NewMongoCardRepository(client *mongo.Client) CardRepository {
    return &MongoCardRepository{client: client}
}

func (r *MongoCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // MongoDB specific code
    // ...
}

func (r *MongoCardRepository) Save(ctx context.Context, card *entities.Card) error {
    // MongoDB specific code
    // ...
}

// ===== Dependency Injection =====
// Todos os princípios SOLID trabalhando juntos!
repo := NewPostgresCardRepository(db)        // OCP: Escolhe implementação
service := NewCardService(repo)              // DIP: Injeta dependência
err := service.Create(ctx, card)             // SRP, ISP, LSP: Todos funcionando!
```

---

### 5.7 SOLID Checklist

Use este checklist ao revisar código:

#### Single Responsibility
- [ ] Esta classe/struct tem apenas uma razão para mudar?
- [ ] Posso descrever o que esta classe faz em uma frase?
- [ ] Esta classe está focada em uma única responsabilidade?

#### Open/Closed
- [ ] Posso adicionar nova funcionalidade sem modificar esta classe?
- [ ] Novas features são adicionadas via novas classes/interfaces?
- [ ] Esta classe é estável (raramente muda)?

#### Liskov Substitution
- [ ] Posso substituir esta classe por sua subclasse sem quebrar nada?
- [ ] Esta implementação honra o contrato da interface?
- [ ] Subclasses fortalecem (não enfraquecem) o contrato base?

#### Interface Segregation
- [ ] Esta interface está focada em uma necessidade específica do cliente?
- [ ] Existem métodos que alguns clientes não precisam?
- [ ] Esta interface deveria ser dividida em menores?

#### Dependency Inversion
- [ ] Esta classe depende de interfaces (não de concretizações)?
- [ ] Dependências são injetadas (não criadas internamente)?
- [ ] Posso trocar implementações sem mudar esta classe?

---

## 🎯 Benefícios dos Princípios SOLID

| Princípio | Benefício |
|-----------|-----------|
| **SRP** | Mais fácil de entender, testar e manter |
| **OCP** | Adiciona features sem quebrar código existente |
| **LSP** | Polimorfismo seguro e substituição |
| **ISP** | Dependências mínimas e focadas |
| **DIP** | Implementações flexíveis, testáveis e substituíveis |

**Juntos**, os princípios SOLID criam:
- ✅ Código **manutenível** (fácil de mudar)
- ✅ Código **testável** (fácil de mockar)
- ✅ Código **flexível** (fácil de estender)
- ✅ Código **profissional** (padrões da indústria)

## 5. Domain-Driven Design (DDD)

### 5.1 Bounded Contexts

O sistema pode ser dividido em contextos delimitados:

1. **Study Context**: Cards, reviews, scheduling
2. **Content Context**: Notes, note types, templates
3. **Organization Context**: Decks, presets, hierarchy
4. **User Context**: Authentication, preferences
5. **Sync Context**: Sincronização multi-dispositivo

### 5.2 Aggregates

- **Deck Aggregate**: Deck (root) + Cards (entidades filhas)
- **Note Aggregate**: Note (root) + Cards (entidades filhas)
- **User Aggregate**: User (root) + Preferences (value object)

### 5.3 Domain Events

Eventos de domínio permitem desacoplamento e extensibilidade:

```go
// internal/domain/events/card_reviewed.go
package events

import (
    "time"
    "github.com/anki/core/domain/valueobjects"
)

type CardReviewed struct {
    CardID    int64
    UserID    int64
    Rating    int
    NewState  valueobjects.CardState
    Timestamp time.Time
}

func (e *CardReviewed) EventType() string {
    return "card.reviewed"
}
```

## 6. Dependency Injection

**Exemplo: `cmd/api/main.go`**

```go
package main

import (
    "database/sql"
    "log"
    "os"
    
    _ "github.com/lib/pq"
    
    app_services "github.com/anki/core/services/services"
    domain_services "github.com/anki/core/domain/services"
    "github.com/anki/infra/persistence/postgres"
    "github.com/anki/infra/messaging"
    "github.com/anki/internal/interfaces/http"
    http_handlers "github.com/anki/app/api/handlers"
    "github.com/anki/config"
    "github.com/anki/pkg/jwt"
)

func main() {
    // 1. Configuração
    cfg := config.Load()
    
    // 2. Infraestrutura
    db := setupDatabase(cfg.DatabaseURL)
    defer db.Close()
    
    // 3. Repositórios (Infrastructure -> Domain interface)
    userRepo := postgres.NewUserRepository(db)
    deckRepo := postgres.NewDeckRepository(db)
    noteRepo := postgres.NewNoteRepository(db)
    cardRepo := postgres.NewCardRepository(db)
    reviewRepo := postgres.NewReviewRepository(db)
    
    // 4. Domain Services
    scheduler := domain_services.NewSM2Scheduler()
    templateRenderer := domain_services.NewTemplateRenderer()
    cardGenerator := domain_services.NewCardGenerator(templateRenderer)
    
    // 5. Event Bus
    eventBus := messaging.NewInMemoryEventBus()
    
    // 6. Application Services
    studyService := app_services.NewStudyService(
        cardRepo,
        reviewRepo,
        deckRepo,
        scheduler,
        eventBus,
    )
    
    deckService := app_services.NewDeckService(deckRepo)
    noteService := app_services.NewNoteService(noteRepo, cardRepo, cardGenerator)
    
    // 7. JWT Service
    jwtService := jwt.NewService(cfg.JWTSecret)
    
    // 8. Handlers
    studyHandler := http_handlers.NewStudyHandler(studyService)
    deckHandler := http_handlers.NewDeckHandler(deckService)
    noteHandler := http_handlers.NewNoteHandler(noteService)
    
    // 9. Router
    router := http.SetupRouter(
        nil, // authHandler seria criado aqui
        deckHandler,
        noteHandler,
        studyHandler,
        jwtService,
    )
    
    // 10. Server
    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }
    
    server := &http.Server{
        Addr:    ":" + port,
        Handler: router,
    }
    
    log.Printf("Server starting on port %s", port)
    log.Fatal(server.ListenAndServe())
}

func setupDatabase(databaseURL string) *sql.DB {
    db, err := sql.Open("postgres", databaseURL)
    if err != nil {
        log.Fatal("Failed to connect to database:", err)
    }
    
    if err := db.Ping(); err != nil {
        log.Fatal("Failed to ping database:", err)
    }
    
    return db
}
```

## 7. Testing Guide

### 7.1 Testing Pyramid

```
        /\
       /  \
      / E2E \          (Poucos testes - cenários completos)
     /------\
    /        \
   /Integration\       (Testes médios - camadas integradas)
  /------------\
 /              \
/   Unit Tests   \     (Muitos testes - unidades isoladas)
\----------------/
```

**Distribuição Recomendada**:
- **Unit Tests**: 70% (testes rápidos, isolados)
- **Integration Tests**: 20% (testes com banco, APIs)
- **E2E Tests**: 10% (testes completos end-to-end)

### 7.2 Unit Testing

#### 7.2.1 Domain Layer Tests

**Exemplo: `core/domain/entities/card_test.go`**

```go
package entities_test

import (
    "testing"
    "time"
    
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/valueobjects"
    "github.com/stretchr/testify/assert"
)

func TestCard_IsDue(t *testing.T) {
    tests := []struct {
        name     string
        card     *entities.Card
        now      int64
        expected bool
    }{
        {
            name: "Card is due",
            card: &entities.Card{
                Due:      1000,
                Suspended: false,
                Buried:   false,
            },
            now:      2000,
            expected: true,
        },
        {
            name: "Card is not due yet",
            card: &entities.Card{
                Due:      3000,
                Suspended: false,
                Buried:   false,
            },
            now:      2000,
            expected: false,
        },
        {
            name: "Suspended card is not due",
            card: &entities.Card{
                Due:      1000,
                Suspended: true,
                Buried:   false,
            },
            now:      2000,
            expected: false,
        },
        {
            name: "Buried card is not due",
            card: &entities.Card{
                Due:      1000,
                Suspended: false,
                Buried:   true,
            },
            now:      2000,
            expected: false,
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := tt.card.IsDue(tt.now)
            assert.Equal(t, tt.expected, result)
        })
    }
}

func TestCard_MarkAsReviewed(t *testing.T) {
    card := &entities.Card{
        State:    valueobjects.CardStateNew,
        Interval: 0,
        Ease:     2500,
        Reps:     0,
    }
    
    card.MarkAsReviewed(3, 86400, 2500) // Rating 3, interval 1 day
    
    assert.Equal(t, valueobjects.CardStateReview, card.State)
    assert.Equal(t, 86400, card.Interval)
    assert.Equal(t, 2500, card.Ease)
    assert.Equal(t, 1, card.Reps)
    assert.NotNil(t, card.LastReviewAt)
}
```

#### 7.2.2 Service Layer Tests (com Mocks)

**Exemplo: `core/services/services/deck_service_test.go`**

```go
package services_test

import (
    "context"
    "testing"
    "time"
    
    "github.com/anki/core/services/services"
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/repositories"
    "github.com/anki/pkg/errors"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
)

// MockRepository é um mock do DeckRepository
type MockDeckRepository struct {
    mock.Mock
}

func (m *MockDeckRepository) FindByID(ctx context.Context, id int64) (*entities.Deck, error) {
    args := m.Called(ctx, id)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*entities.Deck), args.Error(1)
}

func (m *MockDeckRepository) Save(ctx context.Context, deck *entities.Deck) (*entities.Deck, error) {
    args := m.Called(ctx, deck)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*entities.Deck), args.Error(1)
}

func (m *MockDeckRepository) FindByName(ctx context.Context, userID int64, name string) (*entities.Deck, error) {
    args := m.Called(ctx, userID, name)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*entities.Deck), args.Error(1)
}

func TestDeckService_CreateDeck(t *testing.T) {
    ctx := context.Background()
    mockRepo := new(MockDeckRepository)
    service := services.NewDeckService(mockRepo)
    
    t.Run("Success", func(t *testing.T) {
        deck := &entities.Deck{
            UserID: 1,
            Name:   "New Deck",
        }
        
        savedDeck := &entities.Deck{
            ID:     123,
            UserID: 1,
            Name:   "New Deck",
            CreatedAt: time.Now(),
        }
        
        // Setup mocks
        mockRepo.On("FindByName", ctx, int64(1), "New Deck").Return(nil, nil)
        mockRepo.On("Save", ctx, deck).Return(savedDeck, nil)
        
        // Execute
        result, err := service.CreateDeck(ctx, deck)
        
        // Assert
        assert.NoError(t, err)
        assert.Equal(t, savedDeck.ID, result.ID)
        assert.Equal(t, savedDeck.Name, result.Name)
        mockRepo.AssertExpectations(t)
    })
    
    t.Run("Duplicate name", func(t *testing.T) {
        deck := &entities.Deck{
            UserID: 1,
            Name:   "Existing Deck",
        }
        
        existingDeck := &entities.Deck{
            ID:   456,
            Name: "Existing Deck",
        }
        
        // Setup mocks
        mockRepo.On("FindByName", ctx, int64(1), "Existing Deck").Return(existingDeck, nil)
        
        // Execute
        result, err := service.CreateDeck(ctx, deck)
        
        // Assert
        assert.Error(t, err)
        assert.True(t, errors.IsConflict(err))
        assert.Nil(t, result)
        mockRepo.AssertExpectations(t)
    })
}
```

### 7.3 Integration Testing

#### 7.3.1 Repository Tests com Database Real

**Exemplo: `infra/persistence/postgres/card_repository_test.go`**

```go
package postgres_test

import (
    "context"
    "testing"
    "time"
    
    "github.com/anki/core/domain/entities"
    "github.com/anki/infra/persistence/postgres"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func setupTestDB(t *testing.T) *sql.DB {
    // Conectar ao banco de teste
    db, err := sql.Open("postgres", "postgres://test:test@localhost/anki_test?sslmode=disable")
    require.NoError(t, err)
    
    // Limpar dados de teste
    db.Exec("TRUNCATE TABLE cards, notes, decks CASCADE")
    
    return db
}

func TestCardRepository_FindByID(t *testing.T) {
    db := setupTestDB(t)
    defer db.Close()
    
    repo := postgres.NewCardRepository(db)
    ctx := context.Background()
    
    // Criar card de teste
    card := &entities.Card{
        NoteID:    1,
        CardTypeID: 0,
        DeckID:    1,
        Due:       1234567890,
        State:     valueobjects.CardStateNew,
    }
    
    saved, err := repo.Save(ctx, card)
    require.NoError(t, err)
    require.NotZero(t, saved.ID)
    
    // Buscar por ID
    found, err := repo.FindByID(ctx, saved.ID)
    
    // Assert
    assert.NoError(t, err)
    assert.NotNil(t, found)
    assert.Equal(t, saved.ID, found.ID)
    assert.Equal(t, saved.NoteID, found.NoteID)
}

func TestCardRepository_FindDueCards(t *testing.T) {
    db := setupTestDB(t)
    defer db.Close()
    
    repo := postgres.NewCardRepository(db)
    ctx := context.Background()
    
    now := time.Now().Unix()
    
    // Criar cards de teste
    dueCard := &entities.Card{DeckID: 1, Due: now - 1000, Suspended: false, Buried: false}
    futureCard := &entities.Card{DeckID: 1, Due: now + 1000, Suspended: false, Buried: false}
    
    repo.Save(ctx, dueCard)
    repo.Save(ctx, futureCard)
    
    // Buscar cards due
    filter := &filters.CardFilter{
        BaseFilter: filters.BaseFilter{Limit: 100},
        DeckID: 1,
        DueBefore: now,
    }
    
    cards, err := repo.FindAll(ctx, filter)
    
    // Assert
    assert.NoError(t, err)
    assert.Len(t, cards, 1)
    assert.Equal(t, dueCard.ID, cards[0].ID)
}
```

#### 7.3.2 API Endpoint Tests

**Exemplo: `app/api/http/handlers/deck_handler_test.go`**

```go
package handlers_test

import (
    "bytes"
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "testing"
    
    "github.com/anki/app/api/handlers"
    "github.com/anki/core/services/services"
    "github.com/anki/infra/persistence/postgres"
    "github.com/stretchr/testify/assert"
)

func TestDeckHandler_CreateDeck(t *testing.T) {
    // Setup
    db := setupTestDB(t)
    repo := postgres.NewDeckRepository(db)
    service := services.NewDeckService(repo)
    handler := handlers.NewDeckHandler(service)
    
    // Request
    reqBody := map[string]interface{}{
        "name": "Test Deck",
    }
    body, _ := json.Marshal(reqBody)
    
    req := httptest.NewRequest("POST", "/api/v1/decks", bytes.NewReader(body))
    req.Header.Set("Content-Type", "application/json")
    req.Header.Set("Authorization", "Bearer test-token")
    
    w := httptest.NewRecorder()
    
    // Execute
    handler.CreateDeck(w, req)
    
    // Assert
    assert.Equal(t, http.StatusCreated, w.Code)
    
    var response map[string]interface{}
    json.Unmarshal(w.Body.Bytes(), &response)
    assert.NotNil(t, response["data"])
}
```

### 7.4 E2E Testing

**Exemplo: `tests/e2e/study_flow_test.go`**

```go
package e2e_test

import (
    "bytes"
    "encoding/json"
    "net/http"
    "testing"
    
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestStudyFlow_E2E(t *testing.T) {
    baseURL := "http://localhost:8080"
    
    // 1. Login
    loginReq := map[string]string{
        "email":    "test@example.com",
        "password": "password123",
    }
    loginBody, _ := json.Marshal(loginReq)
    
    resp, err := http.Post(baseURL+"/api/v1/auth/login", "application/json", bytes.NewReader(loginBody))
    require.NoError(t, err)
    assert.Equal(t, http.StatusOK, resp.StatusCode)
    
    var loginResp map[string]interface{}
    json.NewDecoder(resp.Body).Decode(&loginResp)
    token := loginResp["data"].(map[string]interface{})["access_token"].(string)
    
    // 2. Get next card
    req, _ := http.NewRequest("GET", baseURL+"/api/v1/study/next-card", nil)
    req.Header.Set("Authorization", "Bearer "+token)
    
    resp, err = http.DefaultClient.Do(req)
    require.NoError(t, err)
    assert.Equal(t, http.StatusOK, resp.StatusCode)
    
    var cardResp map[string]interface{}
    json.NewDecoder(resp.Body).Decode(&cardResp)
    cardID := cardResp["data"].(map[string]interface{})["id"].(float64)
    
    // 3. Answer card
    answerReq := map[string]interface{}{
        "card_id": cardID,
        "rating":  3,
        "time_ms": 5000,
    }
    answerBody, _ := json.Marshal(answerReq)
    
    req, _ = http.NewRequest("POST", baseURL+"/api/v1/study/answer", bytes.NewReader(answerBody))
    req.Header.Set("Authorization", "Bearer "+token)
    req.Header.Set("Content-Type", "application/json")
    
    resp, err = http.DefaultClient.Do(req)
    require.NoError(t, err)
    assert.Equal(t, http.StatusOK, resp.StatusCode)
}
```

### 7.5 Test Fixtures e Factories

**Exemplo: `internal/test/fixtures/deck_factory.go`**

```go
package fixtures

import (
    "github.com/anki/core/domain/entities"
    "time"
)

// DeckFactory cria decks de teste
type DeckFactory struct{}

func NewDeckFactory() *DeckFactory {
    return &DeckFactory{}
}

func (f *DeckFactory) Create(opts ...DeckOption) *entities.Deck {
    deck := &entities.Deck{
        UserID:    1,
        Name:      "Test Deck",
        CreatedAt: time.Now(),
        UpdatedAt: time.Now(),
    }
    
    for _, opt := range opts {
        opt(deck)
    }
    
    return deck
}

type DeckOption func(*entities.Deck)

func WithUserID(userID int64) DeckOption {
    return func(d *entities.Deck) {
        d.UserID = userID
    }
}

func WithName(name string) DeckOption {
    return func(d *entities.Deck) {
        d.Name = name
    }
}

// Uso
deck := fixtures.NewDeckFactory().Create(
    fixtures.WithUserID(123),
    fixtures.WithName("Custom Deck"),
)
```

### 7.6 Test Coverage Goals

**Coverage Targets**:
- **Domain Layer**: 90%+ (lógica de negócio crítica)
- **Application Layer**: 80%+ (orquestração)
- **Infrastructure Layer**: 70%+ (adapters)
- **Interfaces Layer**: 70%+ (handlers)

**Comandos**:

```bash
# Rodar testes com coverage
go test -cover ./...

# Coverage detalhado
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Coverage por pacote
go test -cover ./internal/domain/...
go test -cover ./internal/application/...
```

### 7.7 Test Commands Reference

```bash
# Rodar todos os testes
go test ./...

# Rodar testes de um pacote específico
go test ./internal/domain/entities

# Rodar testes com verbose
go test -v ./...

# Rodar testes com race detector
go test -race ./...

# Rodar apenas testes unitários (sem integração)
go test -short ./...

# Rodar testes em paralelo
go test -parallel 4 ./...

# Rodar testes com timeout
go test -timeout 30s ./...
```

Com interfaces, é fácil criar mocks:

```go
// tests/unit/services/study_service_test.go
package services_test

import (
    "context"
    "testing"
    "time"
    
    "github.com/anki/core/services/services"
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/repositories"
    "github.com/anki/core/domain/valueobjects"
)

type mockCardRepository struct {
    cards map[int64]*entities.Card
}

func (m *mockCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    card, ok := m.cards[id]
    if !ok {
        return nil, repositories.ErrCardNotFound
    }
    return card, nil
}

func (m *mockCardRepository) FindByNoteID(ctx context.Context, noteID int64) ([]*entities.Card, error) {
    return nil, nil
}

func (m *mockCardRepository) FindDueCards(ctx context.Context, deckID int64, now int64, limit int) ([]*entities.Card, error) {
    return nil, nil
}

func (m *mockCardRepository) FindNewCards(ctx context.Context, deckID int64, limit int) ([]*entities.Card, error) {
    return nil, nil
}

func (m *mockCardRepository) Save(ctx context.Context, card *entities.Card) error {
    m.cards[card.ID] = card
    return nil
}

func (m *mockCardRepository) SaveMany(ctx context.Context, cards []*entities.Card) error {
    return nil
}

func (m *mockCardRepository) Delete(ctx context.Context, id int64) error {
    delete(m.cards, id)
    return nil
}

func (m *mockCardRepository) CountByDeck(ctx context.Context, deckID int64, state valueobjects.CardState) (int, error) {
    return 0, nil
}

type mockDeckRepository struct {
    decks map[int64]*entities.Deck
}

func (m *mockDeckRepository) FindByID(ctx context.Context, id int64) (*entities.Deck, error) {
    deck, ok := m.decks[id]
    if !ok {
        return nil, repositories.ErrDeckNotFound
    }
    return deck, nil
}

func (m *mockDeckRepository) FindByUserID(ctx context.Context, userID int64) ([]*entities.Deck, error) {
    return nil, nil
}

func (m *mockDeckRepository) FindByParentID(ctx context.Context, parentID int64) ([]*entities.Deck, error) {
    return nil, nil
}

func (m *mockDeckRepository) Save(ctx context.Context, deck *entities.Deck) error {
    m.decks[deck.ID] = deck
    return nil
}

func (m *mockDeckRepository) Delete(ctx context.Context, id int64) error {
    return nil
}

func (m *mockDeckRepository) Exists(ctx context.Context, userID int64, name string, parentID *int64) (bool, error) {
    return false, nil
}

type mockReviewRepository struct{}

func (m *mockReviewRepository) Save(ctx context.Context, review *entities.Review) error {
    return nil
}

func (m *mockReviewRepository) FindByCardID(ctx context.Context, cardID int64, limit int) ([]*entities.Review, error) {
    return nil, nil
}

func (m *mockReviewRepository) FindByCardIDAndDateRange(ctx context.Context, cardID int64, startDate, endDate time.Time) ([]*entities.Review, error) {
    return nil, nil
}

func (m *mockReviewRepository) CountByCardID(ctx context.Context, cardID int64) (int, error) {
    return 0, nil
}

type mockScheduler struct{}

func (m *mockScheduler) CalculateInterval(
    card *entities.Card,
    rating int,
    deckOptions *valueobjects.DeckOptions,
) (*domain_services.SchedulingResult, error) {
    return &domain_services.SchedulingResult{
        NewInterval: 1,
        NewEase:     2500,
        NewState:    valueobjects.CardStateReview,
        NewDue:      time.Now().UnixMilli() + 86400000,
    }, nil
}

type mockEventBus struct{}

func (m *mockEventBus) Publish(ctx context.Context, event interface{}) error {
    return nil
}

func TestStudyService_AnswerCard(t *testing.T) {
    mockCardRepo := &mockCardRepository{
        cards: make(map[int64]*entities.Card),
    }
    
    mockDeckRepo := &mockDeckRepository{
        decks: make(map[int64]*entities.Deck),
    }
    
    card := &entities.Card{
        ID:     1,
        DeckID: 1,
        State:  valueobjects.CardStateNew,
        Ease:   2500,
    }
    mockCardRepo.cards[1] = card
    
    deck := &entities.Deck{
        ID:     1,
        UserID: 1,
        Options: &valueobjects.DeckOptions{
            LearningSteps: []int{60, 600, 86400},
        },
    }
    mockDeckRepo.decks[1] = deck
    
    service := services.NewStudyService(
        mockCardRepo,
        &mockReviewRepository{},
        mockDeckRepo,
        &mockScheduler{},
        &mockEventBus{},
    )
    
    result, err := service.AnswerCard(context.Background(), 1, 1, 3, 5000)
    if err != nil {
        t.Fatalf("Expected no error, got %v", err)
    }
    
    if result.CardID != 1 {
        t.Errorf("Expected CardID 1, got %d", result.CardID)
    }
}
```

## 8. Performance Optimization

### 8.1 N+1 Query Problem

#### ❌ Bad: N+1 Queries

```go
// BAD: N+1 queries (1 + N database calls)
func (r *CardRepository) FindAllWithDecks(ctx context.Context, filter *filters.CardFilter) ([]*entities.Card, error) {
    // Query 1: Buscar cards
    query := `SELECT id, note_id, deck_id, due, interval, ease, state FROM cards WHERE ...`
    rows, err := r.db.QueryContext(ctx, query, ...)
    // ... scan cards
    
    // Query N: Para cada card, buscar deck (N queries!)
    for _, card := range cards {
        deck, err := r.deckRepo.FindByID(ctx, card.DeckID) // N queries!
        card.Deck = deck
    }
    
    return cards, nil
}

// Se 100 cards → 101 database queries! 😱
```

#### ✅ Good: JOIN para Evitar N+1

```go
// GOOD: Single query com JOIN (1 database call)
func (r *CardRepository) FindAllWithDecks(ctx context.Context, filter *filters.CardFilter) ([]*entities.Card, error) {
    // Single query com JOIN
    query := `
        SELECT 
            c.id, c.note_id, c.deck_id, c.due, c.interval, c.ease, c.state,
            d.id as deck_id, d.name as deck_name, d.user_id as deck_user_id
        FROM cards c
        LEFT JOIN decks d ON c.deck_id = d.id
        WHERE c.suspended = FALSE AND c.buried = FALSE
        ORDER BY c.due ASC
        LIMIT $1 OFFSET $2
    `
    
    rows, err := r.db.QueryContext(ctx, query, filter.GetLimit(), filter.GetOffset())
    if err != nil {
        return nil, err
    }
    defer rows.Close()
    
    var cards []*entities.Card
    for rows.Next() {
        card := &entities.Card{}
        deck := &entities.Deck{}
        
        err := rows.Scan(
            &card.ID, &card.NoteID, &card.DeckID, &card.Due,
            &card.Interval, &card.Ease, &card.State,
            &deck.ID, &deck.Name, &deck.UserID,
        )
        if err != nil {
            return nil, err
        }
        
        // Associar deck ao card (sem query adicional!)
        card.Deck = deck
        cards = append(cards, card)
    }
    
    return cards, nil
}

// 100 cards → 1 database query! ⚡
```

**Speed improvement**: 100x mais rápido!

### 8.2 Connection Pooling

**Exemplo: `infra/persistence/postgres/database.go`**

```go
package postgres

import (
    "database/sql"
    "time"
    
    _ "github.com/lib/pq"
)

// Config contém configuração do connection pool
type Config struct {
    URL             string
    MaxOpenConns    int           // Máximo de conexões abertas
    MaxIdleConns    int           // Máximo de conexões idle
    ConnMaxLifetime time.Duration // Tempo máximo de vida da conexão
    ConnMaxIdleTime time.Duration // Tempo máximo idle antes de fechar
}

// NewDatabase cria conexão com pool configurado
func NewDatabase(config Config) (*sql.DB, error) {
    db, err := sql.Open("postgres", config.URL)
    if err != nil {
        return nil, err
    }
    
    // Configurar connection pool
    db.SetMaxOpenConns(config.MaxOpenConns)    // Default: 25
    db.SetMaxIdleConns(config.MaxIdleConns)   // Default: 5
    db.SetConnMaxLifetime(config.ConnMaxLifetime) // Default: 5 minutos
    db.SetConnMaxIdleTime(config.ConnMaxIdleTime) // Default: 10 minutos
    
    // Verificar conexão
    if err := db.Ping(); err != nil {
        return nil, err
    }
    
    return db, nil
}

// Configuração recomendada
var DefaultConfig = Config{
    MaxOpenConns:    25,              // Máximo de conexões simultâneas
    MaxIdleConns:    5,               // Manter 5 conexões idle
    ConnMaxLifetime: 5 * time.Minute, // Reciclar conexões a cada 5 min
    ConnMaxIdleTime: 10 * time.Minute, // Fechar conexões idle após 10 min
}
```

**Por que Connection Pooling?**:
- Criar nova conexão: 50-100ms (caro!)
- Reusar conexão do pool: <1ms (rápido!)
- Pool gerencia conexões automaticamente

### 8.3 Async/Concurrent Operations (Goroutines)

#### ❌ Bad: Operações Sequenciais

```go
// BAD: Operações sequenciais (3 segundos total!)
func (s *StudyService) GetStudySession(ctx context.Context, userID int64) (*StudySession, error) {
    // 1 segundo
    user, err := s.userRepo.FindByID(ctx, userID)
    if err != nil {
        return nil, err
    }
    
    // 1 segundo
    deck, err := s.deckRepo.FindByID(ctx, user.DefaultDeckID)
    if err != nil {
        return nil, err
    }
    
    // 1 segundo
    stats, err := s.statsRepo.GetUserStats(ctx, userID)
    if err != nil {
        return nil, err
    }
    
    return &StudySession{User: user, Deck: deck, Stats: stats}, nil
}
```

#### ✅ Good: Operações Paralelas com Goroutines

```go
// GOOD: Operações paralelas (1 segundo total!)
import "golang.org/x/sync/errgroup"

func (s *StudyService) GetStudySession(ctx context.Context, userID int64) (*StudySession, error) {
    var user *entities.User
    var deck *entities.Deck
    var stats *entities.Stats
    
    g, ctx := errgroup.WithContext(ctx)
    
    // Buscar user
    g.Go(func() error {
        u, err := s.userRepo.FindByID(ctx, userID)
        if err != nil {
            return err
        }
        user = u
        return nil
    })
    
    // Buscar deck (após ter user)
    g.Go(func() error {
        d, err := s.deckRepo.FindByID(ctx, user.DefaultDeckID)
        if err != nil {
            return err
        }
        deck = d
        return nil
    })
    
    // Buscar stats
    g.Go(func() error {
        st, err := s.statsRepo.GetUserStats(ctx, userID)
        if err != nil {
            return err
        }
        stats = st
        return nil
    })
    
    // Aguardar todas as goroutines
    if err := g.Wait(); err != nil {
        return nil, err
    }
    
    return &StudySession{User: user, Deck: deck, Stats: stats}, nil
}
```

**Speed improvement**: 3x mais rápido!

### 8.4 Background Tasks (Worker Pools)

**Exemplo: `infra/jobs/worker_pool.go`**

```go
package jobs

import (
    "context"
    "sync"
    "time"
    "log"
)

// Job representa uma tarefa em background
type Job interface {
    Execute(ctx context.Context) error
    RetryCount() int
    MaxRetries() int
}

// WorkerPool gerencia pool de workers para processar jobs
type WorkerPool struct {
    workers    int
    jobQueue   chan Job
    wg         sync.WaitGroup
    ctx        context.Context
    cancel     context.CancelFunc
}

// NewWorkerPool cria novo worker pool
func NewWorkerPool(workers int, queueSize int) *WorkerPool {
    ctx, cancel := context.WithCancel(context.Background())
    
    return &WorkerPool{
        workers:  workers,
        jobQueue: make(chan Job, queueSize),
        ctx:      ctx,
        cancel:   cancel,
    }
}

// Start inicia workers
func (wp *WorkerPool) Start() {
    for i := 0; i < wp.workers; i++ {
        wp.wg.Add(1)
        go wp.worker(i)
    }
}

// Enqueue adiciona job à fila
func (wp *WorkerPool) Enqueue(job Job) error {
    select {
    case wp.jobQueue <- job:
        return nil
    case <-wp.ctx.Done():
        return wp.ctx.Err()
    }
}

// worker processa jobs da fila
func (wp *WorkerPool) worker(id int) {
    defer wp.wg.Done()
    
    for {
        select {
        case job := <-wp.jobQueue:
            if err := job.Execute(wp.ctx); err != nil {
                // Retry logic
                if job.RetryCount() < job.MaxRetries() {
                    // Re-enqueue com retry
                    go func() {
                        time.Sleep(time.Second * time.Duration(job.RetryCount()+1))
                        wp.Enqueue(job)
                    }()
                } else {
                    // Max retries reached - log error
                    log.Printf("Worker %d: Job failed after %d retries: %v", id, job.MaxRetries(), err)
                }
            }
        case <-wp.ctx.Done():
            return
        }
    }
}

// Stop para workers
func (wp *WorkerPool) Stop() {
    wp.cancel()
    close(wp.jobQueue)
    wp.wg.Wait()
}
```

**Uso**:

```go
// Criar worker pool
pool := jobs.NewWorkerPool(10, 100) // 10 workers, fila de 100 jobs
pool.Start()
defer pool.Stop()

// Enfileirar jobs
pool.Enqueue(&MediaCleanupJob{...})
pool.Enqueue(&EmailNotificationJob{...})
```

### 8.5 Caching Strategies

#### 8.5.1 Cache-Aside Pattern

**Exemplo: `infra/cache/cache_aside.go`**

```go
package cache

import (
    "context"
    "encoding/json"
    "time"
    
    "github.com/redis/go-redis/v9"
)

// CacheAside implementa padrão cache-aside
type CacheAside struct {
    redis *redis.Client
    ttl   time.Duration
}

func NewCacheAside(redis *redis.Client, ttl time.Duration) *CacheAside {
    return &CacheAside{
        redis: redis,
        ttl:   ttl,
    }
}

// GetOrSet busca do cache ou executa função e cacheia resultado
func (c *CacheAside) GetOrSet(
    ctx context.Context,
    key string,
    fn func() (interface{}, error),
) (interface{}, error) {
    // 1. Tentar cache primeiro
    data, err := c.redis.Get(ctx, key).Result()
    if err == nil {
        // Cache hit
        var result interface{}
        if err := json.Unmarshal([]byte(data), &result); err == nil {
            return result, nil
        }
    }
    
    // 2. Cache miss - executar função
    result, err := fn()
    if err != nil {
        return nil, err
    }
    
    // 3. Cachear resultado
    data, _ = json.Marshal(result)
    c.redis.Set(ctx, key, data, c.ttl)
    
    return result, nil
}
```

**Uso no Repository**:

```go
func (r *CardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    cacheKey := fmt.Sprintf("card:%d", id)
    
    card, err := r.cache.GetOrSet(ctx, cacheKey, func() (interface{}, error) {
        // Função executada apenas em cache miss
        return r.db.FindByID(ctx, id)
    })
    
    if err != nil {
        return nil, err
    }
    
    return card.(*entities.Card), nil
}
```

#### 8.5.2 Write-Through Cache

```go
// Write-Through: Escreve no cache E no database simultaneamente
func (r *CardRepository) Save(ctx context.Context, card *entities.Card) error {
    // 1. Salvar no database
    if err := r.db.Save(ctx, card); err != nil {
        return err
    }
    
    // 2. Atualizar cache
    cacheKey := fmt.Sprintf("card:%d", card.ID)
    data, _ := json.Marshal(card)
    r.cache.Set(ctx, cacheKey, data, 1*time.Hour)
    
    return nil
}
```

### 8.6 Query Optimization

#### 8.6.1 EXPLAIN ANALYZE

```sql
-- Analisar query performance
EXPLAIN ANALYZE
SELECT c.*, d.name as deck_name
FROM cards c
JOIN decks d ON c.deck_id = d.id
WHERE c.due <= 1234567890
  AND c.suspended = FALSE
  AND c.buried = FALSE
ORDER BY c.due ASC
LIMIT 20;

-- Verificar se índices estão sendo usados
-- Se "Seq Scan" aparecer → criar índice!
```

#### 8.6.2 Índices Estratégicos

```sql
-- Índices para queries frequentes
CREATE INDEX idx_cards_due_state ON cards(due, state) 
WHERE suspended = FALSE AND buried = FALSE;

CREATE INDEX idx_cards_deck_due ON cards(deck_id, due);

CREATE INDEX idx_notes_user_guid ON notes(user_id, guid);

-- Índice parcial (apenas para registros não deletados)
CREATE INDEX idx_decks_user_active ON decks(user_id, name) 
WHERE deleted_at IS NULL;
```

### 8.7 Batch Operations

**Exemplo: `infra/persistence/postgres/card_repository.go`**

```go
// SaveMany salva múltiplos cards em uma transação
func (r *CardRepository) SaveMany(ctx context.Context, cards []*entities.Card) error {
    tx, err := r.db.BeginTx(ctx, nil)
    if err != nil {
        return err
    }
    defer tx.Rollback()
    
    stmt, err := tx.PrepareContext(ctx, `
        INSERT INTO cards (note_id, card_type_id, deck_id, due, interval, ease, state)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING id
    `)
    if err != nil {
        return err
    }
    defer stmt.Close()
    
    for _, card := range cards {
        err := stmt.QueryRowContext(ctx,
            card.NoteID, card.CardTypeID, card.DeckID,
            card.Due, card.Interval, card.Ease, string(card.State),
        ).Scan(&card.ID)
        if err != nil {
            return err
        }
    }
    
    return tx.Commit()
}

// DeleteMany deleta múltiplos cards
func (r *CardRepository) DeleteMany(ctx context.Context, cardIDs []int64) error {
    query := `DELETE FROM cards WHERE id = ANY($1)`
    _, err := r.db.ExecContext(ctx, query, pq.Array(cardIDs))
    return err
}
```

### 8.8 Performance Metrics

**Exemplo: `pkg/metrics/metrics.go`**

```go
package metrics

import (
    "time"
    "sync"
)

var (
    requestDuration = make(map[string][]time.Duration)
    requestCount     = make(map[string]int64)
    mu               sync.RWMutex
)

// RecordRequest registra métrica de requisição
func RecordRequest(endpoint string, duration time.Duration) {
    mu.Lock()
    defer mu.Unlock()
    
    requestCount[endpoint]++
    requestDuration[endpoint] = append(requestDuration[endpoint], duration)
    
    // Manter apenas últimas 1000 métricas
    if len(requestDuration[endpoint]) > 1000 {
        requestDuration[endpoint] = requestDuration[endpoint][1:]
    }
}

// GetAverageDuration retorna duração média
func GetAverageDuration(endpoint string) time.Duration {
    mu.RLock()
    defer mu.RUnlock()
    
    durations := requestDuration[endpoint]
    if len(durations) == 0 {
        return 0
    }
    
    var total time.Duration
    for _, d := range durations {
        total += d
    }
    
    return total / time.Duration(len(durations))
}
```

## 9. Security Best Practices

### 9.1 OWASP Top 10

#### 9.1.1 Broken Access Control (#1 Risk)

**Problema**: Usuários podem acessar recursos que não deveriam.

```go
// ❌ BAD: Sem verificação de autorização
func (h *DeckHandler) GetDeck(w http.ResponseWriter, r *http.Request) {
    deckID := getDeckIDFromPath(r.URL.Path)
    deck, err := h.service.GetDeck(r.Context(), deckID)
    // Qualquer usuário autenticado pode acessar QUALQUER deck! 😱
    json.NewEncoder(w).Encode(deck)
}

// ✅ GOOD: Verificar ownership
func (h *DeckHandler) GetDeck(w http.ResponseWriter, r *http.Request) {
    deckID := getDeckIDFromPath(r.URL.Path)
    userID := getUserIDFromContext(r.Context())
    
    deck, err := h.service.GetDeck(r.Context(), userID, deckID)
    if err != nil {
        if errors.IsNotFound(err) {
            http.Error(w, "Deck not found", http.StatusNotFound)
            return
        }
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    
    // Service verifica ownership internamente
    if deck.UserID != userID {
        http.Error(w, "Access denied", http.StatusForbidden)
        return
    }
    
    json.NewEncoder(w).Encode(deck)
}
```

**Prevenção**:
- ✅ Deny by default
- ✅ Verificar permissões em todos os endpoints
- ✅ Usar RBAC (Role-Based Access Control)
- ✅ Logar falhas de autorização

#### 9.1.2 Cryptographic Failures (#2 Risk)

**Problema**: Dados sensíveis expostos.

```go
// ❌ BAD: Armazenar senha em plaintext
type User struct {
    Password string // Plaintext password! 😱
}

// ✅ GOOD: Hash senha com bcrypt
import "golang.org/x/crypto/bcrypt"

func HashPassword(password string) (string, error) {
    // Cost factor 12 (balance entre segurança e performance)
    bytes, err := bcrypt.GenerateFromPassword([]byte(password), 12)
    if err != nil {
        return "", err
    }
    return string(bytes), nil
}

func VerifyPassword(plainPassword, hashedPassword string) bool {
    err := bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(plainPassword))
    return err == nil
}

// Uso
hashed, _ := HashPassword("user123")
user.PasswordHash = hashed

// Verificar login
if VerifyPassword(loginPassword, user.PasswordHash) {
    // Login válido
}
```

**Prevenção**:
- ✅ Usar bcrypt/argon2 para senhas (NÃO md5/sha1)
- ✅ Usar AES-256 para criptografia de dados
- ✅ Armazenar chaves em vaults seguros (AWS KMS, HashiCorp Vault)
- ✅ Usar HTTPS para dados em trânsito (TLS 1.3)
- ✅ Nunca commitar secrets no git

#### 9.1.3 Injection (#3 Risk)

**SQL Injection**:

```go
// ❌ BAD: String interpolation (SQL injection!)
email := r.URL.Query().Get("email")
query := fmt.Sprintf("SELECT * FROM users WHERE email = '%s'", email)
// Attacker input: ' OR '1'='1' --
// Result: SELECT * FROM users WHERE email = '' OR '1'='1' --'
// Retorna TODOS os usuários! 😱

// ✅ GOOD: Prepared statements (sempre!)
email := r.URL.Query().Get("email")
query := "SELECT * FROM users WHERE email = $1"
row := db.QueryRow(query, email) // Safe! Parâmetros sanitizados
```

**Command Injection**:

```go
// ❌ BAD: Executar comandos shell com input do usuário
filename := r.URL.Query().Get("file")
exec.Command("cat", filename).Run() // Command injection!

// ✅ GOOD: Validar e usar bibliotecas seguras
filename := r.URL.Query().Get("file")
if !isValidFilename(filename) {
    return errors.New("Invalid filename")
}
// Usar biblioteca segura para ler arquivo
data, err := os.ReadFile(filepath.Join("/safe/path", filename))
```

### 9.2 Password Hashing

**Exemplo: `pkg/security/password.go`**

```go
package security

import (
    "golang.org/x/crypto/bcrypt"
)

const (
    // Cost factor: balance entre segurança e performance
    // 10 = rápido, 12 = balanceado, 14+ = muito lento
    bcryptCost = 12
)

// HashPassword cria hash bcrypt da senha
func HashPassword(password string) (string, error) {
    bytes, err := bcrypt.GenerateFromPassword([]byte(password), bcryptCost)
    if err != nil {
        return "", err
    }
    return string(bytes), nil
}

// VerifyPassword verifica se senha corresponde ao hash
func VerifyPassword(plainPassword, hashedPassword string) bool {
    err := bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(plainPassword))
    return err == nil
}

// NeedsRehash verifica se hash precisa ser atualizado (cost factor aumentou)
func NeedsRehash(hashedPassword string) bool {
    cost, err := bcrypt.Cost([]byte(hashedPassword))
    if err != nil {
        return true
    }
    return cost < bcryptCost
}
```

### 9.3 SQL Injection Prevention

**Sempre usar Prepared Statements**:

```go
// ✅ GOOD: Prepared statements (padrão em Go)
func (r *CardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    query := "SELECT id, note_id, deck_id, due, interval, ease, state FROM cards WHERE id = $1"
    row := r.db.QueryRowContext(ctx, query, id) // $1 é substituído de forma segura
    
    var card entities.Card
    err := row.Scan(&card.ID, &card.NoteID, &card.DeckID, &card.Due, &card.Interval, &card.Ease, &card.State)
    if err != nil {
        return nil, err
    }
    return &card, nil
}

// ✅ GOOD: Múltiplos parâmetros
query := "SELECT * FROM cards WHERE deck_id = $1 AND state = $2 AND due <= $3"
rows, err := db.QueryContext(ctx, query, deckID, state, due)
```

### 9.4 Security Headers

**Exemplo: `app/api/http/middleware/security_headers_middleware.go`**

```go
package middleware

import "net/http"

func SecurityHeadersMiddleware() func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            // Prevenir MIME type sniffing
            w.Header().Set("X-Content-Type-Options", "nosniff")
            
            // Prevenir clickjacking
            w.Header().Set("X-Frame-Options", "DENY")
            
            // XSS Protection (legacy, mas ainda útil)
            w.Header().Set("X-XSS-Protection", "1; mode=block")
            
            // HSTS (HTTP Strict Transport Security)
            w.Header().Set("Strict-Transport-Security", "max-age=31536000; includeSubDomains; preload")
            
            // Content Security Policy
            w.Header().Set("Content-Security-Policy", "default-src 'self'")
            
            // Referrer Policy
            w.Header().Set("Referrer-Policy", "strict-origin-when-cross-origin")
            
            // Permissions Policy
            w.Header().Set("Permissions-Policy", "geolocation=(), microphone=(), camera=()")
            
            next.ServeHTTP(w, r)
        })
    }
}
```

### 9.5 Authentication & Session Management

**JWT Best Practices**:

```go
// ✅ GOOD: JWT com expiração curta + refresh tokens
type TokenPair struct {
    AccessToken  string `json:"access_token"`
    RefreshToken string `json:"refresh_token"`
    ExpiresIn    int    `json:"expires_in"` // segundos
}

// Access token: 15-30 minutos
// Refresh token: 7-30 dias
// Refresh token armazenado em Redis com TTL
```

**Session Management**:

```go
// ✅ GOOD: Rotação de tokens
func (s *AuthService) RefreshToken(ctx context.Context, refreshToken string) (*TokenPair, error) {
    // 1. Validar refresh token
    claims, err := s.validateRefreshToken(refreshToken)
    if err != nil {
        return nil, errors.NewAuthenticationError("Invalid refresh token")
    }
    
    // 2. Verificar se token não foi revogado (Redis)
    if s.isTokenRevoked(refreshToken) {
        return nil, errors.NewAuthenticationError("Token revoked")
    }
    
    // 3. Revogar refresh token antigo
    s.revokeToken(refreshToken)
    
    // 4. Gerar novo par de tokens
    return s.generateTokenPair(claims.UserID)
}
```

### 9.6 Data Protection

**Encryption at Rest**:

```go
// ✅ GOOD: Criptografar dados sensíveis antes de salvar
import "crypto/aes"
import "crypto/cipher"

func EncryptData(data []byte, key []byte) ([]byte, error) {
    block, err := aes.NewCipher(key)
    if err != nil {
        return nil, err
    }
    
    gcm, err := cipher.NewGCM(block)
    if err != nil {
        return nil, err
    }
    
    nonce := make([]byte, gcm.NonceSize())
    if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
        return nil, err
    }
    
    ciphertext := gcm.Seal(nonce, nonce, data, nil)
    return ciphertext, nil
}
```

**Encryption in Transit**:
- ✅ Sempre usar HTTPS (TLS 1.3)
- ✅ Validar certificados SSL
- ✅ Não permitir conexões HTTP em produção

### 9.7 Security Testing

**Exemplo: Security Test**:

```go
func TestSQLInjectionPrevention(t *testing.T) {
    // Tentar SQL injection
    maliciousInput := "'; DROP TABLE users; --"
    
    // Deve retornar erro de validação, não executar SQL
    _, err := service.FindByEmail(ctx, maliciousInput)
    assert.Error(t, err)
    assert.True(t, errors.IsValidation(err))
}

func TestAuthorizationCheck(t *testing.T) {
    // User 1 tenta acessar deck de User 2
    user1ID := int64(1)
    user2DeckID := int64(999)
    
    _, err := service.GetDeck(ctx, user1ID, user2DeckID)
    assert.Error(t, err)
    assert.True(t, errors.IsAuthorization(err))
}
```

## 10. Diagramas de Sequência

### 10.1 Fluxo de Resposta de Card

```mermaid
sequenceDiagram
    participant Client
    participant Handler
    participant StudyService
    participant CardRepo
    participant DeckRepo
    participant Scheduler
    participant ReviewRepo
    participant EventBus

    Client->>Handler: POST /study/answer
    Handler->>StudyService: AnswerCard(userID, cardID, rating, timeMs)
    StudyService->>CardRepo: FindByID(cardID)
    CardRepo-->>StudyService: card
    StudyService->>DeckRepo: FindByID(card.DeckID)
    DeckRepo-->>StudyService: deck
    StudyService->>StudyService: Validate ownership
    StudyService->>Scheduler: CalculateInterval(card, rating, options)
    Scheduler-->>StudyService: SchedulingResult
    StudyService->>CardRepo: Save(card)
    StudyService->>ReviewRepo: Save(review)
    StudyService->>EventBus: Publish(CardReviewed)
    StudyService-->>Handler: AnswerCardResult
    Handler-->>Client: 200 OK {data: result}
```

### 10.2 Fluxo de Criação de Note

```mermaid
sequenceDiagram
    participant Client
    participant Handler
    participant NoteService
    participant NoteRepo
    participant CardGenerator
    participant CardRepo

    Client->>Handler: POST /notes
    Handler->>NoteService: CreateNote(userID, noteTypeID, deckID, fields, tags)
    NoteService->>NoteService: Generate GUID
    NoteService->>NoteRepo: Save(note)
    NoteRepo-->>NoteService: note (com ID)
    NoteService->>CardGenerator: GenerateCards(note, noteType, deckID)
    CardGenerator-->>NoteService: cards[]
    NoteService->>CardRepo: SaveMany(cards)
    NoteService-->>Handler: note
    Handler-->>Client: 201 Created {data: note}
```

## 11. Diagramas de Componentes

### 11.1 Dependências entre Camadas

```mermaid
graph TB
    subgraph Interfaces["Interfaces Layer"]
        HTTP[HTTP Handlers]
        WS[WebSocket Handlers]
    end
    
    subgraph Application["Application Layer"]
        AppServices[Application Services]
        DTOs[DTOs]
        Mappers[Mappers]
    end
    
    subgraph Domain["Domain Layer"]
        Entities[Entities]
        ValueObjects[Value Objects]
        DomainServices[Domain Services]
        Events[Domain Events]
        RepoInterfaces[Repository Interfaces]
    end
    
    subgraph Infrastructure["Infrastructure Layer"]
        PostgresRepo[PostgreSQL Repositories]
        Storage[Storage Adapters]
        Cache[Cache Adapters]
        EventBus[Event Bus]
    end
    
    HTTP --> AppServices
    WS --> AppServices
    AppServices --> Entities
    AppServices --> DomainServices
    AppServices --> RepoInterfaces
    AppServices --> DTOs
    AppServices --> Mappers
    Entities --> ValueObjects
    DomainServices --> RepoInterfaces
    PostgresRepo --> RepoInterfaces
    AppServices --> EventBus
    EventBus --> Events
```

## 12. Guia de Contribuição

### 12.1 Adicionando uma Nova Entidade

1. Criar entidade em `internal/domain/entities/`
2. Criar value objects relacionados em `internal/domain/valueobjects/`
3. Criar interface de repositório em `internal/domain/repositories/`
4. Implementar repositório em `internal/infrastructure/persistence/postgres/`
5. Criar application service em `internal/application/services/`
6. Criar DTOs em `internal/application/dto/`
7. Criar handlers em `internal/interfaces/http/handlers/`
8. Adicionar rotas em `internal/interfaces/http/router.go`

### 12.2 Adicionando um Novo Domain Service

1. Criar interface em `internal/domain/services/`
2. Implementar serviço em `internal/domain/services/`
3. Injetar no application service que precisa
4. Adicionar testes unitários

### 12.3 Adicionando um Novo Adapter

1. Criar interface no domain (se necessário)
2. Implementar adapter em `internal/infrastructure/`
3. Registrar no `main.go`

## 13. Clean Code Principles (Princípios de Código Limpo)

### 13.1 Nomes Significativos

#### ❌ Bad Names

```go
// BAD: Nomes não revelam intenção
d := 30
x := getData()
temp := calculate()
list1, list2, list3 := []int{}, []int{}, []int{}
```

#### ✅ Good Names

```go
// GOOD: Nomes revelam intenção
daysSinceCreation := 30
userProfile := getUserProfile()
totalPrice := calculateOrderTotal()
activeUsers, inactiveUsers, pendingUsers := []int{}, []int{}, []int{}
```

**Regras**:
- Use nomes que **revelam intenção**
- Use nomes **pronunciáveis**
- Use nomes **pesquisáveis** (evite letras únicas)
- Evite **mapeamento mental** (o que significa `i`?)
- Use termos do **domínio**

### 13.2 Funções Pequenas e Focadas

#### ❌ Bad: Função Grande

```go
// BAD: Função faz tudo (200+ linhas)
func ProcessOrder(orderID string) error {
    // Validar order (20 linhas)
    // Verificar inventário (30 linhas)
    // Calcular preço (40 linhas)
    // Aplicar descontos (25 linhas)
    // Processar pagamento (35 linhas)
    // Atualizar inventário (20 linhas)
    // Enviar email (15 linhas)
    // ... (continua)
}
```

#### ✅ Good: Funções Pequenas e Focadas

```go
// GOOD: Função orquestra, delega para funções focadas
func ProcessOrder(orderID string) error {
    order := validateOrder(orderID)
    checkInventoryAvailability(order)
    total := calculateTotalPrice(order)
    applyCustomerDiscounts(order, total)
    processPayment(order, total)
    updateInventoryLevels(order)
    sendConfirmationEmail(order)
    trackOrderAnalytics(order)
}

// Cada função faz UMA coisa
func validateOrder(orderID string) (*Order, error) {
    // 5-10 linhas apenas
}

func checkInventoryAvailability(order *Order) error {
    // 5-10 linhas apenas
}
```

**Regras**:
- Funções devem fazer **UMA coisa**
- **Pequenas** (5-20 linhas idealmente)
- **Um nível de abstração** por função
- **Nomes descritivos** (nome diz o que faz)

### 13.3 DRY (Don't Repeat Yourself)

#### ❌ Bad: Duplicação

```go
// Duplicação de lógica de validação
func CreateUser(name string, email string) error {
    if name == "" || len(name) < 2 {
        return errors.New("name too short")
    }
    if !strings.Contains(email, "@") {
        return errors.New("invalid email")
    }
    // ... criar user
}

func UpdateUser(userID string, name string, email string) error {
    if name == "" || len(name) < 2 { // DUPLICADO!
        return errors.New("name too short")
    }
    if !strings.Contains(email, "@") { // DUPLICADO!
        return errors.New("invalid email")
    }
    // ... atualizar user
}
```

#### ✅ Good: Extrair Lógica Comum

```go
// GOOD: Fonte única de verdade para validação
func ValidateUserData(name string, email string) error {
    if name == "" || len(name) < 2 {
        return errors.New("name must be at least 2 characters")
    }
    if !strings.Contains(email, "@") {
        return errors.New("invalid email address")
    }
    return nil
}

func CreateUser(name string, email string) error {
    if err := ValidateUserData(name, email); err != nil {
        return err
    }
    // ... criar user
}

func UpdateUser(userID string, name string, email string) error {
    if err := ValidateUserData(name, email); err != nil {
        return err
    }
    // ... atualizar user
}
```

### 13.4 Comentários Explicam POR QUÊ, Não O QUÊ

#### ❌ Bad Comments

```go
// BAD: Comentários explicam O QUÊ (código já diz isso)
// Incrementar contador
counter++

// Loop através de users
for _, user := range users {
    // Verificar se user está ativo
    if user.IsActive {
        // Imprimir nome do user
        fmt.Println(user.Name)
    }
}
```

#### ✅ Good Comments

```go
// GOOD: Explica POR QUÊ
// Incrementamos antes de verificar porque o primeiro item é índice 1 na API externa
counter++

// Legacy: Tabela users tem soft-delete, então devemos filtrar por is_active
// TODO: Remover após migração para tabela archive (JIRA-123)
activeUsers := filterActiveUsers(users)

// Performance: Batch size de 100 previne problemas de memória com 1M+ users
batchSize := 100
```

### 13.5 Tratamento de Erros

#### ❌ Bad: Erros Ignorados

```go
// BAD: Ignora erros
user, _ := getUser(userID)
// ... usar user
```

#### ✅ Good: Tratamento Adequado de Erros

```go
// GOOD: Trata erros específicos
user, err := getUser(userID)
if err != nil {
    if errors.Is(err, ErrUserNotFound) {
        log.Warnf("User not found: %d", userID)
        return nil, errors.NewNotFoundError("User", userID)
    }
    if errors.Is(err, ErrDatabaseError) {
        log.Errorf("Database error: %v", err)
        return nil, errors.New("Internal server error")
    }
    return nil, err
}
```

**Regras**:
- Não ignore erros
- **Trate erros específicos**
- **Registre erros** com contexto
- **Re-lance ou retorne erro significativo**
- Não retorne `nil` para erros (use errors)

## 14. Design Patterns Aplicados

### 14.1 Padrões Criacionais

#### Factory Pattern ⭐

**Uso**: Criação de services com dependências injetadas.

```go
// Factory cria services
type ServiceFactory struct {
    db *sql.DB
}

func (f *ServiceFactory) CreateDeckService() *services.DeckService {
    repo := postgres.NewDeckRepository(f.db)
    return services.NewDeckService(repo)
}
```

#### Singleton Pattern ⭐

**Uso**: Configurações, logger, conexões.

```go
var (
    once     sync.Once
    settings *Settings
)

func GetSettings() *Settings {
    once.Do(func() {
        settings = loadSettings()
    })
    return settings
}
```

### 14.2 Padrões Estruturais

#### Adapter Pattern ⭐⭐ (Muito Usado)

**Uso**: Múltiplos repositórios (PostgreSQL, Redis, MongoDB).

```go
// Interface (Target)
type CardRepository interface {
    FindByID(ctx context.Context, id int64) (*entities.Card, error)
}

// Adapter 1: PostgreSQL
type PostgresCardRepository struct {
    db *sql.DB
}

// Adapter 2: Redis
type RedisCardRepository struct {
    client *redis.Client
}

// Adapter 3: MongoDB
type MongoCardRepository struct {
    client *mongo.Client
}
```

#### Mapper Pattern ⭐⭐ (Muito Usado)

**Uso**: Conversão Domain ↔ Database ↔ DTO.

```go
type CardMapper struct{}

func (m *CardMapper) ToDomain(dbCard *DBCard) *entities.Card {
    // Converte database model para domain entity
}

func (m *CardMapper) ToDatabase(card *entities.Card) *DBCard {
    // Converte domain entity para database model
}
```

### 14.3 Padrões Comportamentais

#### Strategy Pattern ⭐

**Uso**: Múltiplos algoritmos de scheduling (SM-2, FSRS).

```go
type SchedulerService interface {
    CalculateInterval(card *entities.Card, rating int) (*SchedulingResult, error)
}

type SM2Scheduler struct{}
type FSRSScheduler struct{}

// Service usa strategy sem saber qual implementação
type StudyService struct {
    scheduler SchedulerService // Strategy
}
```

#### Observer Pattern

**Uso**: Domain Events (CardReviewed, NoteCreated).

```go
type EventBus interface {
    Publish(ctx context.Context, event DomainEvent) error
    Subscribe(eventType string, handler EventHandler)
}

// Handlers observam eventos
type EmailNotificationHandler struct{}
func (h *EmailNotificationHandler) Handle(event CardReviewedEvent) {
    // Enviar email
}
```

### 14.4 Padrões Enterprise

#### Repository Pattern ⭐⭐⭐ (Core Pattern)

**Uso**: Abstração de acesso a dados.

```go
type CardRepository interface {
    FindAll(ctx context.Context, filter *filters.CardFilter) ([]*entities.Card, error)
    FindByID(ctx context.Context, id int64) (*entities.Card, error)
    Save(ctx context.Context, card *entities.Card) error
    Delete(ctx context.Context, id int64) error
    Count(ctx context.Context, filter *filters.CardFilter) (int, error)
}
```

#### Service Layer Pattern ⭐⭐

**Uso**: Orquestração de casos de uso.

```go
type CardService struct {
    repo secondary.ICardRepository
}

func (s *CardService) ReviewCard(ctx context.Context, cardID int64, rating int) error {
    // Orquestra: busca card, calcula intervalo, salva
}
```

#### DTO Pattern ⭐⭐

**Uso**: Transferência de dados entre camadas.

```go
// Request DTO
type CreateCardRequest struct {
    NoteID    int64 `json:"note_id" validate:"required"`
    CardTypeID int  `json:"card_type_id" validate:"required"`
    DeckID    int64 `json:"deck_id" validate:"required"`
}

// Response DTO
type CardResponse struct {
    ID        int64  `json:"id"`
    NoteID    int64  `json:"note_id"`
    State     string `json:"state"`
    CreatedAt string `json:"created_at"`
}
```

### 14.5 Inventário de Padrões

| Padrão | Categoria | Onde Usado | Propósito |
|--------|-----------|------------|-----------|
| **Repository** | Enterprise | Todos os repositórios | Abstração de acesso a dados |
| **Service Layer** | Enterprise | Todos os services | Orquestração de casos de uso |
| **Factory** | Creational | ServiceFactory | Criação de services |
| **Singleton** | Creational | Settings, Logger | Instância única |
| **Adapter** | Structural | Repositórios múltiplos | Adaptar diferentes implementações |
| **Mapper** | Enterprise | Todos os mappers | Conversão Domain ↔ DB ↔ DTO |
| **DTO** | Enterprise | API layer | Transferência de dados |
| **Strategy** | Behavioral | Schedulers | Algoritmos intercambiáveis |
| **Observer** | Behavioral | Event Bus | Event-driven architecture |
| **Dependency Injection** | Enterprise | Em todo lugar | Injeção de dependências |

## 15. Padrões de Código

### 15.1 Convenções de Nomenclatura

- **Entidades**: PascalCase singular (`Card`, `Deck`, `Note`)
- **Value Objects**: PascalCase (`Email`, `CardState`, `GUID`)
- **Repositórios**: Interface `XxxRepository`, Implementação `xxxRepository`
- **Services**: Interface `XxxService`, Implementação `xxxService`
- **Handlers**: `XxxHandler` com métodos `XxxHandler`

### 13.2 Tratamento de Erros

- Usar erros customizados do pacote `errors`
- Retornar erros específicos do domínio (`ErrCardNotFound`)
- Não expor detalhes internos em respostas HTTP

### 13.3 Logging

- Usar structured logging (JSON)
- Incluir contexto relevante (userID, requestID)
- Níveis apropriados (DEBUG, INFO, WARN, ERROR)

## 14. Considerações de Escalabilidade

### 14.1 Horizontal Scaling

- Aplicação é stateless (exceto WebSocket)
- Sessões podem ser compartilhadas via Redis
- Load balancer pode distribuir requisições

### 14.2 Otimizações de Banco

- Índices em colunas frequentemente consultadas
- Particionamento por `user_id` para grandes volumes
- Connection pooling configurado adequadamente

### 14.3 Caching

- Cache de estatísticas (Redis)
- Cache de templates renderizados
- Cache de resultados de busca frequentes

## 15. Monitoramento e Observabilidade

### 15.1 Métricas (Prometheus)

**Exemplo: `pkg/metrics/prometheus.go`**

```go
package metrics

import (
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promauto"
)

var (
    // HTTP Request metrics
    httpRequestsTotal = promauto.NewCounterVec(
        prometheus.CounterOpts{
            Name: "http_requests_total",
            Help: "Total number of HTTP requests",
        },
        []string{"method", "endpoint", "status"},
    )
    
    httpRequestDuration = promauto.NewHistogramVec(
        prometheus.HistogramOpts{
            Name:    "http_request_duration_seconds",
            Help:    "HTTP request duration in seconds",
            Buckets: prometheus.DefBuckets,
        },
        []string{"method", "endpoint"},
    )
    
    // Database metrics
    dbQueryDuration = promauto.NewHistogramVec(
        prometheus.HistogramOpts{
            Name:    "db_query_duration_seconds",
            Help:    "Database query duration in seconds",
        },
        []string{"query", "operation"},
    )
    
    // Business metrics
    cardsReviewedTotal = promauto.NewCounterVec(
        prometheus.CounterOpts{
            Name: "cards_reviewed_total",
            Help: "Total number of cards reviewed",
        },
        []string{"rating"},
    )
)

// RecordHTTPRequest registra métrica de requisição HTTP
func RecordHTTPRequest(method, endpoint string, statusCode int, duration float64) {
    httpRequestsTotal.WithLabelValues(method, endpoint, fmt.Sprintf("%d", statusCode)).Inc()
    httpRequestDuration.WithLabelValues(method, endpoint).Observe(duration)
}

// RecordDBQuery registra métrica de query de banco
func RecordDBQuery(query, operation string, duration float64) {
    dbQueryDuration.WithLabelValues(query, operation).Observe(duration)
}

// RecordCardReviewed registra métrica de card revisado
func RecordCardReviewed(rating int) {
    cardsReviewedTotal.WithLabelValues(fmt.Sprintf("%d", rating)).Inc()
}
```

**Middleware para métricas**:

```go
func MetricsMiddleware() func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            start := time.Now()
            
            // Wrapper para capturar status code
            rw := &responseWriter{ResponseWriter: w, statusCode: http.StatusOK}
            
            next.ServeHTTP(rw, r)
            
            duration := time.Since(start).Seconds()
            metrics.RecordHTTPRequest(r.Method, r.URL.Path, rw.statusCode, duration)
        })
    }
}
```

### 15.2 Health Checks

**Exemplo: `app/api/http/handlers/health_handler.go`**

```go
package handlers

import (
    "context"
    "database/sql"
    "encoding/json"
    "net/http"
    "time"
    
    "github.com/redis/go-redis/v9"
)

type HealthHandler struct {
    db    *sql.DB
    redis *redis.Client
}

type HealthResponse struct {
    Status    string            `json:"status"`
    Timestamp string            `json:"timestamp"`
    Checks    map[string]string `json:"checks"`
}

// Liveness check (pod está vivo)
func (h *HealthHandler) Liveness(w http.ResponseWriter, r *http.Request) {
    response := HealthResponse{
        Status:    "healthy",
        Timestamp: time.Now().UTC().Format(time.RFC3339),
        Checks:    map[string]string{},
    }
    
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(http.StatusOK)
    json.NewEncoder(w).Encode(response)
}

// Readiness check (pod está pronto para receber tráfego)
func (h *HealthHandler) Readiness(w http.ResponseWriter, r *http.Request) {
    ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
    defer cancel()
    
    checks := make(map[string]string)
    status := "healthy"
    
    // Check database
    if err := h.db.PingContext(ctx); err != nil {
        checks["database"] = "unhealthy: " + err.Error()
        status = "unhealthy"
    } else {
        checks["database"] = "healthy"
    }
    
    // Check Redis
    if err := h.redis.Ping(ctx).Err(); err != nil {
        checks["redis"] = "unhealthy: " + err.Error()
        status = "unhealthy"
    } else {
        checks["redis"] = "healthy"
    }
    
    response := HealthResponse{
        Status:    status,
        Timestamp: time.Now().UTC().Format(time.RFC3339),
        Checks:    checks,
    }
    
    statusCode := http.StatusOK
    if status == "unhealthy" {
        statusCode = http.StatusServiceUnavailable
    }
    
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(statusCode)
    json.NewEncoder(w).Encode(response)
}
```

**Rotas**:

```go
router.HandleFunc("/health/live", healthHandler.Liveness).Methods("GET")
router.HandleFunc("/health/ready", healthHandler.Readiness).Methods("GET")
```

### 15.3 Distributed Tracing (OpenTelemetry)

**Exemplo: Setup OpenTelemetry**:

```go
import (
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/exporters/jaeger"
    "go.opentelemetry.io/otel/sdk/trace"
)

func setupTracing(serviceName string) (*trace.TracerProvider, error) {
    exporter, err := jaeger.New(jaeger.WithCollectorEndpoint(
        jaeger.WithEndpoint("http://localhost:14268/api/traces"),
    ))
    if err != nil {
        return nil, err
    }
    
    tp := trace.NewTracerProvider(
        trace.WithBatcher(exporter),
        trace.WithResource(resource.NewWithAttributes(
            semconv.SchemaURL,
            semconv.ServiceNameKey.String(serviceName),
        )),
    )
    
    otel.SetTracerProvider(tp)
    return tp, nil
}
```

**Uso em handlers**:

```go
import "go.opentelemetry.io/otel"

func (h *DeckHandler) GetDeck(w http.ResponseWriter, r *http.Request) {
    ctx, span := otel.Tracer("anki").Start(r.Context(), "GetDeck")
    defer span.End()
    
    // ... código do handler
}
```

### 15.4 APM (Application Performance Monitoring)

**Integração com Datadog/New Relic**:

```go
// Exemplo: Custom metrics para APM
func (s *StudyService) AnswerCard(ctx context.Context, cardID int64, rating int) error {
    start := time.Now()
    defer func() {
        duration := time.Since(start)
        // Enviar para APM
        apm.RecordMetric("study.answer_card.duration", duration.Milliseconds())
        apm.RecordMetric("study.answer_card.rating", float64(rating))
    }()
    
    // ... lógica do serviço
}
```

### 15.5 Alerting Strategies

**Exemplo: Alertas baseados em métricas**:

```yaml
# Prometheus alert rules
groups:
  - name: anki_alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        annotations:
          summary: "High error rate detected"
      
      - alert: HighLatency
        expr: histogram_quantile(0.95, http_request_duration_seconds) > 1
        for: 5m
        annotations:
          summary: "95th percentile latency > 1s"
      
      - alert: DatabaseDown
        expr: up{job="anki-db"} == 0
        for: 1m
        annotations:
          summary: "Database is down"
```

### 15.6 Dashboards (Grafana)

**Métricas importantes para dashboard**:
- Request rate (requests/second)
- Error rate (%)
- Latency (p50, p95, p99)
- Database connection pool usage
- Cache hit rate
- Active users
- Cards reviewed per minute

## 26. Logging Estruturado e Middleware

### 26.1 Configuração de Logging Estruturado

**Exemplo: `pkg/logger/logger.go`**

```go
package logger

import (
    "encoding/json"
    "fmt"
    "io"
    "log/slog"
    "os"
    "time"
)

// LoggerConfig contém configuração do logger
type LoggerConfig struct {
    Level       string // "DEBUG", "INFO", "WARN", "ERROR"
    Environment string // "development", "production"
    Output      io.Writer
}

// SetupLogger configura logger estruturado
func SetupLogger(config LoggerConfig) *slog.Logger {
    var level slog.Level
    switch config.Level {
    case "DEBUG":
        level = slog.LevelDebug
    case "INFO":
        level = slog.LevelInfo
    case "WARN":
        level = slog.LevelWarn
    case "ERROR":
        level = slog.LevelError
    default:
        level = slog.LevelInfo
    }

    var handler slog.Handler
    
    if config.Environment == "production" {
        // JSON formatter para produção (fácil parsing por agregadores)
        handler = slog.NewJSONHandler(config.Output, &slog.HandlerOptions{
            Level: level,
            AddSource: true,
        })
    } else {
        // Formatter simples para desenvolvimento
        handler = slog.NewTextHandler(config.Output, &slog.HandlerOptions{
            Level: level,
            AddSource: true,
        })
    }

    return slog.New(handler)
}

// Logger global (singleton)
var defaultLogger *slog.Logger

// InitLogger inicializa logger global
func InitLogger(level, environment string) {
    defaultLogger = SetupLogger(LoggerConfig{
        Level:       level,
        Environment: environment,
        Output:      os.Stdout,
    })
}

// GetLogger retorna logger global
func GetLogger() *slog.Logger {
    if defaultLogger == nil {
        InitLogger("INFO", "development")
    }
    return defaultLogger
}

// LogWithContext adiciona contexto ao logger
func LogWithContext(logger *slog.Logger, ctx map[string]interface{}) *slog.Logger {
    attrs := make([]slog.Attr, 0, len(ctx))
    for k, v := range ctx {
        attrs = append(attrs, slog.Any(k, v))
    }
    return logger.With(attrs...)
}
```

### 26.2 Logging Middleware com Request/Response Tracking

**Exemplo: `app/api/http/middleware/logging_middleware.go`**

```go
package middleware

import (
    "log/slog"
    "net/http"
    "time"
    
    "github.com/anki/pkg/logger"
)

// responseWriter wrapper para capturar status code
type responseWriter struct {
    http.ResponseWriter
    statusCode int
    bytesWritten int64
}

func (rw *responseWriter) WriteHeader(code int) {
    rw.statusCode = code
    rw.ResponseWriter.WriteHeader(code)
}

func (rw *responseWriter) Write(b []byte) (int, error) {
    n, err := rw.ResponseWriter.Write(b)
    rw.bytesWritten += int64(n)
    return n, err
}

// LoggingMiddleware registra todas as requisições e respostas
func LoggingMiddleware(logger *slog.Logger) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            start := time.Now()
            
            // Extrair informações da requisição
            requestID := r.Header.Get("X-Request-ID")
            if requestID == "" {
                requestID = generateRequestID()
            }
            
            // Adicionar request ID ao contexto
            ctx := r.Context()
            ctx = context.WithValue(ctx, "request_id", requestID)
            r = r.WithContext(ctx)
            
            // Criar response writer wrapper
            rw := &responseWriter{
                ResponseWriter: w,
                statusCode:     http.StatusOK,
            }
            
            // Log request
            logger.Info("Request started",
                "request_id", requestID,
                "method", r.Method,
                "path", r.URL.Path,
                "query", r.URL.RawQuery,
                "client_ip", getClientIP(r),
                "user_agent", r.UserAgent(),
            )
            
            // Processar requisição
            next.ServeHTTP(rw, r)
            
            // Calcular duração
            duration := time.Since(start)
            
            // Log response
            logger.Info("Request completed",
                "request_id", requestID,
                "method", r.Method,
                "path", r.URL.Path,
                "status_code", rw.statusCode,
                "duration_ms", duration.Milliseconds(),
                "bytes_written", rw.bytesWritten,
            )
        })
    }
}

func getClientIP(r *http.Request) string {
    // Verificar X-Forwarded-For (proxies/load balancers)
    if ip := r.Header.Get("X-Forwarded-For"); ip != "" {
        return ip
    }
    // Verificar X-Real-IP
    if ip := r.Header.Get("X-Real-IP"); ip != "" {
        return ip
    }
    // Fallback para RemoteAddr
    return r.RemoteAddr
}

func generateRequestID() string {
    // Gerar UUID ou usar timestamp + random
    return fmt.Sprintf("%d-%d", time.Now().UnixNano(), rand.Int63())
}
```

### 26.3 Request ID Middleware

**Exemplo: `app/api/http/middleware/request_id_middleware.go`**

```go
package middleware

import (
    "context"
    "crypto/rand"
    "encoding/hex"
    "net/http"
)

type contextKey string

const requestIDKey contextKey = "request_id"

// RequestIDMiddleware adiciona request ID a todas as requisições
func RequestIDMiddleware() func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            // Gerar ou extrair request ID
            requestID := r.Header.Get("X-Request-ID")
            if requestID == "" {
                requestID = generateRequestID()
            }
            
            // Adicionar ao contexto
            ctx := context.WithValue(r.Context(), requestIDKey, requestID)
            r = r.WithContext(ctx)
            
            // Adicionar ao header de resposta
            w.Header().Set("X-Request-ID", requestID)
            
            next.ServeHTTP(w, r)
        })
    }
}

// GetRequestID extrai request ID do contexto
func GetRequestID(ctx context.Context) string {
    if id, ok := ctx.Value(requestIDKey).(string); ok {
        return id
    }
    return ""
}

func generateRequestID() string {
    b := make([]byte, 16)
    rand.Read(b)
    return hex.EncodeToString(b)
}
```

### 26.4 Logging em Services com Contexto

**Exemplo: `core/services/services/deck_service.go`**

```go
package services

import (
    "context"
    "log/slog"
    
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/repositories"
    "github.com/anki/core/services/filters"
    "github.com/anki/pkg/logger"
    "github.com/anki/app/api/middleware"
)

type DeckService struct {
    repo   repositories.DeckRepository
    logger *slog.Logger
}

func NewDeckService(repo repositories.DeckRepository) *DeckService {
    return &DeckService{
        repo:   repo,
        logger: logger.GetLogger(),
    }
}

func (s *DeckService) CreateDeck(ctx context.Context, deck *entities.Deck) (*entities.Deck, error) {
    requestID := middleware.GetRequestID(ctx)
    
    // Log com contexto
    s.logger.Info("Creating deck",
        "request_id", requestID,
        "user_id", deck.UserID,
        "deck_name", deck.Name,
        "operation", "create_deck",
    )
    
    // Validação de negócio
    if deck.Name == "" {
        s.logger.Warn("Deck creation failed: name required",
            "request_id", requestID,
            "user_id", deck.UserID,
        )
        return nil, errors.NewValidationError("name", "Deck name is required", nil)
    }
    
    // Verificar duplicata
    existing, err := s.repo.FindByName(ctx, deck.Name)
    if err != nil {
        s.logger.Error("Error checking deck name",
            "request_id", requestID,
            "error", err.Error(),
        )
        return nil, err
    }
    
    if existing != nil {
        s.logger.Warn("Deck creation failed: duplicate name",
            "request_id", requestID,
            "deck_name", deck.Name,
        )
        return nil, errors.NewConflictError("Deck", "name", deck.Name)
    }
    
    // Salvar
    saved, err := s.repo.Save(ctx, deck)
    if err != nil {
        s.logger.Error("Error saving deck",
            "request_id", requestID,
            "error", err.Error(),
        )
        return nil, err
    }
    
    s.logger.Info("Deck created successfully",
        "request_id", requestID,
        "deck_id", saved.ID,
        "deck_name", saved.Name,
    )
    
    return saved, nil
}
```

### 26.5 Log Levels Guide

**Níveis de Log e Quando Usar**:

```go
// DEBUG: Informações detalhadas para debugging
logger.Debug("Processing card",
    "card_id", cardID,
    "current_state", card.State,
    "rating", rating,
)

// INFO: Eventos normais da aplicação
logger.Info("Card reviewed",
    "card_id", cardID,
    "rating", rating,
    "new_interval", result.NewInterval,
)

// WARN: Situações anômalas mas recuperáveis
logger.Warn("Rate limit approaching",
    "user_id", userID,
    "requests_count", count,
    "limit", limit,
)

// ERROR: Erros que requerem atenção mas não param a aplicação
logger.Error("Failed to send email",
    "error", err.Error(),
    "user_id", userID,
    "email", email,
)

// CRITICAL: Erros críticos que podem parar a aplicação
logger.Error("Database connection lost",
    "error", err.Error(),
    "database_url", config.DatabaseURL,
)
```

### 26.6 Log Aggregation (ELK Stack, Loki, CloudWatch)

**Exemplo: Configuração para Filebeat (ELK Stack)**

```go
// Em produção, logs são escritos em arquivo e coletados por Filebeat
package logger

import (
    "log/slog"
    "os"
    "path/filepath"
)

// SetupFileLogger configura logger para arquivo (produção)
func SetupFileLogger(config LoggerConfig) *slog.Logger {
    logDir := "logs"
    os.MkdirAll(logDir, 0755)
    
    logFile, err := os.OpenFile(
        filepath.Join(logDir, "app.log"),
        os.O_CREATE|os.O_WRONLY|os.O_APPEND,
        0644,
    )
    if err != nil {
        panic(err)
    }
    
    // Rotação de logs (usar lumberjack ou similar)
    return SetupLogger(LoggerConfig{
        Level:       config.Level,
        Environment: config.Environment,
        Output:      logFile,
    })
}
```

**Docker Logging Driver**:

```yaml
# docker-compose.yml
services:
  api:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        labels: "environment,service"
```

### 26.7 Log Rotation e Retention

**Exemplo: `pkg/logger/rotating_logger.go`**

```go
package logger

import (
    "gopkg.in/natefinch/lumberjack.v2"
    "log/slog"
)

// SetupRotatingLogger configura logger com rotação automática
func SetupRotatingLogger(config LoggerConfig) *slog.Logger {
    writer := &lumberjack.Logger{
        Filename:   "logs/app.log",
        MaxSize:    10,  // megabytes
        MaxBackups: 5,   // manter 5 backups
        MaxAge:     30,  // dias
        Compress:   true, // comprimir backups antigos
    }
    
    return SetupLogger(LoggerConfig{
        Level:       config.Level,
        Environment: config.Environment,
        Output:      writer,
    })
}
```

### 26.8 Security: Não Logar Dados Sensíveis

**Exemplo: `pkg/logger/sanitizer.go`**

```go
package logger

import (
    "strings"
    "regexp"
)

var sensitiveFields = []string{
    "password",
    "token",
    "secret",
    "api_key",
    "authorization",
    "credit_card",
    "ssn",
}

// Sanitize remove dados sensíveis de logs
func Sanitize(data map[string]interface{}) map[string]interface{} {
    sanitized := make(map[string]interface{})
    
    for k, v := range data {
        key := strings.ToLower(k)
        isSensitive := false
        
        for _, field := range sensitiveFields {
            if strings.Contains(key, field) {
                isSensitive = true
                break
            }
        }
        
        if isSensitive {
            sanitized[k] = "[REDACTED]"
        } else {
            // Sanitizar strings que podem conter dados sensíveis
            if str, ok := v.(string); ok {
                sanitized[k] = sanitizeString(str)
            } else {
                sanitized[k] = v
            }
        }
    }
    
    return sanitized
}

func sanitizeString(s string) string {
    // Remover possíveis tokens JWT
    jwtPattern := regexp.MustCompile(`eyJ[A-Za-z0-9-_=]+\.eyJ[A-Za-z0-9-_=]+\.?[A-Za-z0-9-_.+/=]*`)
    s = jwtPattern.ReplaceAllString(s, "[JWT_TOKEN]")
    
    // Remover possíveis emails (parcialmente)
    emailPattern := regexp.MustCompile(`([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})`)
    s = emailPattern.ReplaceAllString(s, "$1@[REDACTED]")
    
    return s
}
```

**Uso**:

```go
// ❌ BAD: Logar dados sensíveis
logger.Info("User logged in",
    "email", user.Email,
    "password", password, // BAD!
    "token", token,       // BAD!
)

// ✅ GOOD: Sanitizar antes de logar
logger.Info("User logged in",
    logger.Sanitize(map[string]interface{}{
        "email":    user.Email,
        "password": password, // Será redactado
        "token":    token,    // Será redactado
    }),
)
```

## 16. Entidades de Domínio Adicionais

### 16.1 NoteType (Tipo de Nota)

**Exemplo: `core/domain/entities/note_type.go`**

```go
package entities

import (
    "time"
    "encoding/json"
)

// NoteType representa um tipo de nota (modelo de card)
type NoteType struct {
    ID          int64
    UserID      int64
    Name        string
    Fields      []FieldDefinition
    CardTypes   []CardTypeDefinition
    Templates   map[string]string // Front, Back, Styling
    Options     NoteTypeOptions
    CreatedAt   time.Time
    UpdatedAt   time.Time
    DeletedAt   *time.Time
}

// FieldDefinition define um campo de uma note type
type FieldDefinition struct {
    Name     string
    Ord      int
    Required bool
}

// CardTypeDefinition define um tipo de card
type CardTypeDefinition struct {
    Name         string
    Ord          int
    FrontTemplate string
    BackTemplate  string
}

// NoteTypeOptions contém opções do note type
type NoteTypeOptions struct {
    StartingEase float64
    CSS          string
}
```

### 16.2 Media (Arquivo de Mídia)

**Exemplo: `core/domain/entities/media.go`**

```go
package entities

import (
    "time"
)

// Media representa um arquivo de mídia (imagem, áudio, vídeo)
type Media struct {
    ID          int64
    UserID      int64
    Filename    string
    Hash        string // SHA-256 para deduplicação
    MimeType    string
    Size        int64
    StoragePath string
    CreatedAt   time.Time
    DeletedAt   *time.Time
}

// IsImage verifica se o media é uma imagem
func (m *Media) IsImage() bool {
    return m.MimeType != "" && 
           (m.MimeType[:5] == "image")
}

// IsAudio verifica se o media é áudio
func (m *Media) IsAudio() bool {
    return m.MimeType != "" && 
           (m.MimeType[:5] == "audio")
}
```

### 16.3 FilteredDeck (Deck Filtrado)

**Exemplo: `core/domain/entities/filtered_deck.go`**

```go
package entities

import (
    "time"
)

// FilteredDeck representa um deck filtrado (custom study)
type FilteredDeck struct {
    ID           int64
    UserID       int64
    Name         string
    SearchFilter string
    SecondFilter *string
    OrderBy      string // "random", "due", "ease", etc.
    Limit        int
    Reschedule   bool
    CreatedAt    time.Time
    UpdatedAt    time.Time
    DeletedAt    *time.Time
}

// Rebuild reconstrói o filtered deck aplicando os filtros
func (fd *FilteredDeck) Rebuild() {
    // Lógica de rebuild seria implementada no service
}
```

### 16.4 Preset (Preset de Opções)

**Exemplo: `core/domain/entities/preset.go`**

```go
package entities

import (
    "time"
    "github.com/anki/core/domain/valueobjects"
)

// Preset representa um preset de opções de deck
type Preset struct {
    ID          int64
    UserID      int64
    Name        string
    Options     *valueobjects.DeckOptions
    CreatedAt   time.Time
    UpdatedAt   time.Time
    DeletedAt   *time.Time
}
```

## 17. Application Services Adicionais

### 17.1 AuthService (Autenticação)

**Exemplo: `core/services/services/auth_service.go`**

```go
package services

import (
    "context"
    "errors"
    "time"
    
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/repositories"
    "github.com/anki/core/domain/valueobjects"
    "github.com/anki/pkg/jwt"
)

// AuthService orquestra casos de uso de autenticação
type AuthService struct {
    userRepo   repositories.UserRepository
    jwtService *jwt.Service
}

// NewAuthService cria um novo AuthService
func NewAuthService(
    userRepo repositories.UserRepository,
    jwtService *jwt.Service,
) *AuthService {
    return &AuthService{
        userRepo:   userRepo,
        jwtService: jwtService,
    }
}

// RegisterRequest contém dados de registro
type RegisterRequest struct {
    Email    string
    Password string
}

// RegisterResult contém resultado do registro
type RegisterResult struct {
    UserID int64
    Token  string
}

// Register registra um novo usuário
func (s *AuthService) Register(
    ctx context.Context,
    req RegisterRequest,
) (*RegisterResult, error) {
    // 1. Validar e criar email value object
    email, err := valueobjects.NewEmail(req.Email)
    if err != nil {
        return nil, err
    }
    
    // 2. Verificar se email já existe
    exists, err := s.userRepo.ExistsByEmail(ctx, email)
    if err != nil {
        return nil, err
    }
    if exists {
        return nil, errors.New("email já cadastrado")
    }
    
    // 3. Criar senha
    password, err := valueobjects.NewPassword(req.Password)
    if err != nil {
        return nil, err
    }
    
    // 4. Criar usuário
    user := &entities.User{
        Email:        email,
        PasswordHash: password.Hash(),
        CreatedAt:    time.Now(),
        UpdatedAt:    time.Now(),
    }
    
    if err := s.userRepo.Save(ctx, user); err != nil {
        return nil, err
    }
    
    // 5. Gerar token JWT
    token, err := s.jwtService.GenerateToken(map[string]interface{}{
        "user_id": user.ID,
        "email":   email.Value(),
    })
    if err != nil {
        return nil, err
    }
    
    return &RegisterResult{
        UserID: user.ID,
        Token:  token,
    }, nil
}

// LoginRequest contém dados de login
type LoginRequest struct {
    Email    string
    Password string
}

// LoginResult contém resultado do login
type LoginResult struct {
    UserID int64
    Token  string
}

// Login autentica um usuário
func (s *AuthService) Login(
    ctx context.Context,
    req LoginRequest,
) (*LoginResult, error) {
    // 1. Buscar usuário por email
    email, err := valueobjects.NewEmail(req.Email)
    if err != nil {
        return nil, err
    }
    
    user, err := s.userRepo.FindByEmail(ctx, email)
    if err != nil {
        return nil, errors.New("credenciais inválidas")
    }
    
    // 2. Verificar senha
    password := valueobjects.Password{Hash: user.PasswordHash}
    if !password.Verify(req.Password) {
        return nil, errors.New("credenciais inválidas")
    }
    
    // 3. Atualizar último login
    s.userRepo.UpdateLastLogin(ctx, user.ID)
    
    // 4. Gerar token
    token, err := s.jwtService.GenerateToken(map[string]interface{}{
        "user_id": user.ID,
        "email":   email.Value(),
    })
    if err != nil {
        return nil, err
    }
    
    return &LoginResult{
        UserID: user.ID,
        Token:  token,
    }, nil
}
```

### 17.2 SyncService (Sincronização)

**Exemplo: `core/services/services/sync_service.go`**

```go
package services

import (
    "context"
    "time"
    
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/repositories"
)

// SyncService orquestra sincronização multi-dispositivo
type SyncService struct {
    cardRepo   secondary.ICardRepository
    noteRepo   repositories.NoteRepository
    deckRepo   repositories.DeckRepository
    reviewRepo repositories.ReviewRepository
}

// NewSyncService cria um novo SyncService
func NewSyncService(
    cardRepo secondary.ICardRepository,
    noteRepo repositories.NoteRepository,
    deckRepo repositories.DeckRepository,
    reviewRepo repositories.ReviewRepository,
) *SyncService {
    return &SyncService{
        cardRepo:   cardRepo,
        noteRepo:   noteRepo,
        deckRepo:   deckRepo,
        reviewRepo: reviewRepo,
    }
}

// SyncRequest contém dados para sincronização
type SyncRequest struct {
    ClientID     string
    LastSyncTime *time.Time
    Cards        []*entities.Card
    Notes        []*entities.Note
    Reviews      []*entities.Review
}

// SyncResult contém resultado da sincronização
type SyncResult struct {
    ServerTime   time.Time
    CardsToSync  []*entities.Card
    NotesToSync  []*entities.Note
    ReviewsToSync []*entities.Review
    Conflicts    []Conflict
}

// Conflict representa um conflito de sincronização
type Conflict struct {
    Type      string // "card", "note", "review"
    EntityID  int64
    ServerVersion interface{}
    ClientVersion interface{}
}

// Sync sincroniza dados entre cliente e servidor
func (s *SyncService) Sync(
    ctx context.Context,
    userID int64,
    req SyncRequest,
) (*SyncResult, error) {
    result := &SyncResult{
        ServerTime: time.Now(),
        Conflicts:  []Conflict{},
    }
    
    // 1. Buscar mudanças do servidor desde último sync
    if req.LastSyncTime != nil {
        // Buscar cards modificados
        // Buscar notes modificadas
        // Buscar reviews criadas
    }
    
    // 2. Aplicar mudanças do cliente
    for _, card := range req.Cards {
        // Verificar conflitos
        // Aplicar mudanças
        s.cardRepo.Save(ctx, card)
    }
    
    // 3. Resolver conflitos (last-write-wins ou merge)
    
    // 4. Retornar mudanças do servidor
    return result, nil
}
```

### 17.3 StatsService (Estatísticas)

**Exemplo: `core/services/services/stats_service.go`**

```go
package services

import (
    "context"
    "time"
    
    "github.com/anki/core/domain/repositories"
)

// StatsService calcula estatísticas de estudo
type StatsService struct {
    cardRepo   secondary.ICardRepository
    reviewRepo repositories.ReviewRepository
    deckRepo   repositories.DeckRepository
}

// NewStatsService cria um novo StatsService
func NewStatsService(
    cardRepo secondary.ICardRepository,
    reviewRepo repositories.ReviewRepository,
    deckRepo repositories.DeckRepository,
) *StatsService {
    return &StatsService{
        cardRepo:   cardRepo,
        reviewRepo: reviewRepo,
        deckRepo:   deckRepo,
    }
}

// DeckStats contém estatísticas de um deck
type DeckStats struct {
    DeckID           int64
    TotalCards       int
    NewCards         int
    LearningCards    int
    ReviewCards      int
    CardsDueToday    int
    CardsDueTomorrow int
    AverageEase      float64
    TotalReviews     int
    ReviewsToday     int
}

// GetDeckStats retorna estatísticas de um deck
func (s *StatsService) GetDeckStats(
    ctx context.Context,
    deckID int64,
) (*DeckStats, error) {
    stats := &DeckStats{
        DeckID: deckID,
    }
    
    now := time.Now().UnixMilli()
    tomorrow := time.Now().Add(24 * time.Hour).UnixMilli()
    
    // Contar cards por estado
    stats.NewCards, _ = s.cardRepo.CountByDeck(ctx, deckID, valueobjects.CardStateNew)
    stats.LearningCards, _ = s.cardRepo.CountByDeck(ctx, deckID, valueobjects.CardStateLearn)
    stats.ReviewCards, _ = s.cardRepo.CountByDeck(ctx, deckID, valueobjects.CardStateReview)
    
    // Buscar cards due hoje
    dueCards, _ := s.cardRepo.FindDueCards(ctx, deckID, now, 1000)
    stats.CardsDueToday = len(dueCards)
    
    // Buscar cards due amanhã
    dueTomorrow, _ := s.cardRepo.FindDueCards(ctx, deckID, tomorrow, 1000)
    stats.CardsDueTomorrow = len(dueTomorrow)
    
    // Calcular média de ease (seria necessário método no repositório)
    
    return stats, nil
}

// ReviewStats contém estatísticas de revisões
type ReviewStats struct {
    TotalReviews    int
    ReviewsToday    int
    ReviewsThisWeek int
    ReviewsThisMonth int
    AverageTime     float64 // em segundos
    RetentionRate   float64
}

// GetReviewStats retorna estatísticas de revisões
func (s *StatsService) GetReviewStats(
    ctx context.Context,
    userID int64,
    startDate, endDate time.Time,
) (*ReviewStats, error) {
    // Implementação de cálculo de estatísticas
    return &ReviewStats{}, nil
}
```

## 18. Domain Services Adicionais

### 18.1 SearchParser (Parser de Busca)

**Exemplo: `core/domain/services/search_parser.go`**

```go
package services

// SearchParserService parseia queries de busca no formato Anki
type SearchParserService interface {
    Parse(query string) (*SearchQuery, error)
}

// SearchQuery representa uma query de busca parseada
type SearchQuery struct {
    Terms      []SearchTerm
    Operators  []string // "AND", "OR", "NOT"
}

// SearchTerm representa um termo de busca
type SearchTerm struct {
    Field    string // "deck", "tag", "note", "card", "is", "rated", etc.
    Operator string // ":", "=", ">", "<", etc.
    Value    string
}

// SearchParser implementa parsing de queries Anki
type SearchParser struct{}

// NewSearchParser cria um novo SearchParser
func NewSearchParser() *SearchParser {
    return &SearchParser{}
}

// Parse parseia uma query de busca
func (p *SearchParser) Parse(query string) (*SearchQuery, error) {
    // Implementação do parser
    // Suporta sintaxe Anki: "deck:Math", "tag:important", "is:due", etc.
    return &SearchQuery{
        Terms: []SearchTerm{},
    }, nil
}
```

### 18.2 FSRSScheduler (Algoritmo FSRS)

**Exemplo: `core/domain/services/fsrs_scheduler.go`**

```go
package services

import (
    "math"
    "time"
    
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/valueobjects"
)

// FSRSScheduler implementa o algoritmo FSRS (Free Spaced Repetition Scheduler)
type FSRSScheduler struct {
    parameters *valueobjects.FSRSParameters
}

// NewFSRSScheduler cria um novo FSRSScheduler
func NewFSRSScheduler(parameters *valueobjects.FSRSParameters) *FSRSScheduler {
    return &FSRSScheduler{
        parameters: parameters,
    }
}

// CalculateInterval calcula intervalo usando FSRS
func (f *FSRSScheduler) CalculateInterval(
    card *entities.Card,
    rating int,
    deckOptions *valueobjects.DeckOptions,
) (*SchedulingResult, error) {
    result := &SchedulingResult{
        NewEase:  card.Ease,
        NewState: card.State,
    }
    
    now := time.Now().UnixMilli()
    
    // FSRS usa stability e difficulty ao invés de ease
    if card.Stability == nil {
        card.Stability = new(float64)
        *card.Stability = 0.4 // Initial stability
    }
    if card.Difficulty == nil {
        card.Difficulty = new(float64)
        *card.Difficulty = 0.3 // Initial difficulty
    }
    
    // Calcular novo stability e difficulty baseado no rating
    newStability, newDifficulty := f.calculateFSRS(
        *card.Stability,
        *card.Difficulty,
        rating,
        deckOptions.DesiredRetention,
    )
    
    result.NewState = valueobjects.CardStateReview
    
    // Calcular novo intervalo baseado em stability
    newIntervalDays := int(newStability)
    result.NewInterval = newIntervalDays
    result.NewDue = now + int64(newIntervalDays*86400000)
    
    // Atualizar stability e difficulty no card
    card.Stability = &newStability
    card.Difficulty = &newDifficulty
    
    return result, nil
}

// calculateFSRS calcula novos valores de stability e difficulty
func (f *FSRSScheduler) calculateFSRS(
    stability, difficulty float64,
    rating int,
    desiredRetention float64,
) (float64, float64) {
    // Implementação simplificada do algoritmo FSRS
    // Em produção, usar implementação completa com parâmetros W
    
    switch rating {
    case 1: // Again
        newStability := stability * 0.1
        newDifficulty := math.Min(1.0, difficulty + 0.2)
        return newStability, newDifficulty
    case 2: // Hard
        newStability := stability * 0.8
        newDifficulty := math.Min(1.0, difficulty + 0.15)
        return newStability, newDifficulty
    case 3: // Good
        newStability := stability * 1.2
        newDifficulty := math.Max(0.0, difficulty - 0.05)
        return newStability, newDifficulty
    case 4: // Easy
        newStability := stability * 1.5
        newDifficulty := math.Max(0.0, difficulty - 0.1)
        return newStability, newDifficulty
    default:
        return stability, difficulty
    }
}
```

## 19. Infrastructure Adapters Detalhados

### 19.1 Event Bus

**Exemplo: `infra/messaging/event_bus.go`**

```go
package messaging

import (
    "context"
    "sync"
)

// EventBus interface para publicação de eventos
type EventBus interface {
    Publish(ctx context.Context, event interface{}) error
    Subscribe(eventType string, handler EventHandler) error
}

// EventHandler processa eventos
type EventHandler func(ctx context.Context, event interface{}) error

// InMemoryEventBus implementa event bus em memória
type InMemoryEventBus struct {
    handlers map[string][]EventHandler
    mu       sync.RWMutex
}

// NewInMemoryEventBus cria um novo event bus em memória
func NewInMemoryEventBus() *InMemoryEventBus {
    return &InMemoryEventBus{
        handlers: make(map[string][]EventHandler),
    }
}

// Publish publica um evento
func (b *InMemoryEventBus) Publish(ctx context.Context, event interface{}) error {
    eventType := getEventType(event)
    
    b.mu.RLock()
    handlers := b.handlers[eventType]
    b.mu.RUnlock()
    
    for _, handler := range handlers {
        go handler(ctx, event) // Processar assincronamente
    }
    
    return nil
}

// Subscribe inscreve um handler para um tipo de evento
func (b *InMemoryEventBus) Subscribe(eventType string, handler EventHandler) error {
    b.mu.Lock()
    defer b.mu.Unlock()
    
    b.handlers[eventType] = append(b.handlers[eventType], handler)
    return nil
}

// getEventType extrai o tipo do evento
func getEventType(event interface{}) string {
    if e, ok := event.(interface{ EventType() string }); ok {
        return e.EventType()
    }
    return ""
}
```

### 19.2 Redis Cache

**Exemplo: `infra/cache/redis_cache.go`**

```go
package cache

import (
    "context"
    "encoding/json"
    "errors"
    "time"
    
    "github.com/redis/go-redis/v9"
)

// Cache interface para cache
type Cache interface {
    Get(ctx context.Context, key string) ([]byte, error)
    Set(ctx context.Context, key string, value []byte, ttl time.Duration) error
    Delete(ctx context.Context, key string) error
    Exists(ctx context.Context, key string) (bool, error)
    Ping(ctx context.Context) error
}

// RedisCache implementa cache usando Redis
type RedisCache struct {
    client *redis.Client
}

// NewRedisCache cria um novo RedisCache
func NewRedisCache(client *redis.Client) *RedisCache {
    return &RedisCache{client: client}
}

// Get obtém valor do cache
func (c *RedisCache) Get(ctx context.Context, key string) ([]byte, error) {
    val, err := c.client.Get(ctx, key).Bytes()
    if err == redis.Nil {
        return nil, ErrCacheMiss
    }
    return val, err
}

// Set define valor no cache
func (c *RedisCache) Set(ctx context.Context, key string, value []byte, ttl time.Duration) error {
    return c.client.Set(ctx, key, value, ttl).Err()
}

// Delete remove valor do cache
func (c *RedisCache) Delete(ctx context.Context, key string) error {
    return c.client.Del(ctx, key).Err()
}

// Exists verifica se chave existe
func (c *RedisCache) Exists(ctx context.Context, key string) (bool, error) {
    count, err := c.client.Exists(ctx, key).Result()
    return count > 0, err
}

// GetJSON obtém e deserializa JSON
func (c *RedisCache) GetJSON(ctx context.Context, key string, dest interface{}) error {
    data, err := c.Get(ctx, key)
    if err != nil {
        return err
    }
    return json.Unmarshal(data, dest)
}

// SetJSON serializa e define JSON
func (c *RedisCache) SetJSON(ctx context.Context, key string, value interface{}, ttl time.Duration) error {
    data, err := json.Marshal(value)
    if err != nil {
        return err
    }
    return c.Set(ctx, key, data, ttl)
}

// Ping verifica se cache está disponível
func (c *RedisCache) Ping(ctx context.Context) error {
    return c.client.Ping(ctx).Err()
}

var ErrCacheMiss = errors.New("cache miss")
```

### 19.3 Storage Adapters

**Exemplo: `infra/storage/storage.go`**

```go
package storage

import (
    "context"
    "io"
)

// Storage interface para armazenamento de arquivos
type Storage interface {
    Upload(ctx context.Context, path string, reader io.Reader) error
    Download(ctx context.Context, path string) (io.ReadCloser, error)
    Delete(ctx context.Context, path string) error
    Exists(ctx context.Context, path string) (bool, error)
    GetURL(ctx context.Context, path string) (string, error)
}

// LocalStorage implementa storage local
type LocalStorage struct {
    basePath string
}

// NewLocalStorage cria um novo LocalStorage
func NewLocalStorage(basePath string) *LocalStorage {
    return &LocalStorage{basePath: basePath}
}

// Upload faz upload de arquivo
func (s *LocalStorage) Upload(ctx context.Context, path string, reader io.Reader) error {
    // Implementação de upload local
    return nil
}

// Download faz download de arquivo
func (s *LocalStorage) Download(ctx context.Context, path string) (io.ReadCloser, error) {
    // Implementação de download local
    return nil, nil
}

// Delete exclui arquivo
func (s *LocalStorage) Delete(ctx context.Context, path string) error {
    // Implementação de delete local
    return nil
}

// Exists verifica se arquivo existe
func (s *LocalStorage) Exists(ctx context.Context, path string) (bool, error) {
    // Implementação de exists local
    return false, nil
}

// GetURL retorna URL do arquivo
func (s *LocalStorage) GetURL(ctx context.Context, path string) (string, error) {
    return "/media/" + path, nil
}
```

**Exemplo: `infra/storage/s3_storage.go`**

```go
package storage

import (
    "context"
    "io"
    
    "github.com/aws/aws-sdk-go-v2/service/s3"
)

// S3Storage implementa storage usando AWS S3
type S3Storage struct {
    client *s3.Client
    bucket string
}

// NewS3Storage cria um novo S3Storage
func NewS3Storage(client *s3.Client, bucket string) *S3Storage {
    return &S3Storage{
        client: client,
        bucket: bucket,
    }
}

// Upload faz upload para S3
func (s *S3Storage) Upload(ctx context.Context, path string, reader io.Reader) error {
    // Implementação usando AWS SDK
    return nil
}

// Download faz download do S3
func (s *S3Storage) Download(ctx context.Context, path string) (io.ReadCloser, error) {
    // Implementação usando AWS SDK
    return nil, nil
}

// Delete exclui do S3
func (s *S3Storage) Delete(ctx context.Context, path string) error {
    // Implementação usando AWS SDK
    return nil
}

// Exists verifica se existe no S3
func (s *S3Storage) Exists(ctx context.Context, path string) (bool, error) {
    // Implementação usando AWS SDK
    return false, nil
}

// GetURL retorna URL assinada do S3
func (s *S3Storage) GetURL(ctx context.Context, path string) (string, error) {
    // Gerar URL pré-assinada
    return "", nil
}
```

### 19.4 Email Service

**Exemplo: `infra/external/email_service.go`**

```go
package external

import (
    "context"
    "fmt"
)

// EmailService interface para envio de emails
type EmailService interface {
    Send(ctx context.Context, to, subject, body string) error
    SendVerificationEmail(ctx context.Context, to, token string) error
}

// SMTPEmailService implementa envio via SMTP
type SMTPEmailService struct {
    smtpHost string
    smtpPort int
    from     string
}

// NewSMTPEmailService cria um novo SMTPEmailService
func NewSMTPEmailService(host string, port int, from string) *SMTPEmailService {
    return &SMTPEmailService{
        smtpHost: host,
        smtpPort: port,
        from:     from,
    }
}

// Send envia email genérico
func (s *SMTPEmailService) Send(ctx context.Context, to, subject, body string) error {
    // Implementação usando net/smtp ou biblioteca de email
    return nil
}

// SendVerificationEmail envia email de verificação
func (s *SMTPEmailService) SendVerificationEmail(ctx context.Context, to, token string) error {
    subject := "Verifique seu email - Anki"
    body := fmt.Sprintf("Clique no link para verificar: https://anki.com/verify?token=%s", token)
    return s.Send(ctx, to, subject, body)
}
```

### 19.5 Media Processor

**Exemplo: `infra/external/media_processor.go`**

```go
package external

import (
    "context"
    "io"
)

// MediaProcessor processa arquivos de mídia
type MediaProcessor interface {
    ProcessImage(ctx context.Context, reader io.Reader) (io.Reader, error)
    GenerateThumbnail(ctx context.Context, reader io.Reader) (io.Reader, error)
    ExtractAudioMetadata(ctx context.Context, reader io.Reader) (*AudioMetadata, error)
}

// AudioMetadata contém metadados de áudio
type AudioMetadata struct {
    Duration float64 // em segundos
    Bitrate  int
    Format   string
}

// ImageMediaProcessor implementa processamento de imagens
type ImageMediaProcessor struct{}

// NewImageMediaProcessor cria um novo ImageMediaProcessor
func NewImageMediaProcessor() *ImageMediaProcessor {
    return &ImageMediaProcessor{}
}

// ProcessImage processa imagem (redimensiona, otimiza)
func (p *ImageMediaProcessor) ProcessImage(ctx context.Context, reader io.Reader) (io.Reader, error) {
    // Implementação usando biblioteca de processamento de imagem
    return reader, nil
}

// GenerateThumbnail gera thumbnail
func (p *ImageMediaProcessor) GenerateThumbnail(ctx context.Context, reader io.Reader) (io.Reader, error) {
    // Implementação de geração de thumbnail
    return reader, nil
}

// ExtractAudioMetadata extrai metadados de áudio
func (p *ImageMediaProcessor) ExtractAudioMetadata(ctx context.Context, reader io.Reader) (*AudioMetadata, error) {
    // Implementação de extração de metadados
    return nil, nil
}
```

## 20. WebSocket Handlers

**Exemplo: `app/api/websocket/sync_handler.go`**

```go
package websocket

import (
    "encoding/json"
    "log"
    "net/http"
    
    "github.com/anki/core/services/services"
    "github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
    CheckOrigin: func(r *http.Request) bool {
        return true // Em produção, validar origem
    },
}

// SyncHandler gerencia conexões WebSocket para sincronização
type SyncHandler struct {
    syncService *services.SyncService
    connections map[int64]*websocket.Conn
}

// NewSyncHandler cria um novo SyncHandler
func NewSyncHandler(syncService *services.SyncService) *SyncHandler {
    return &SyncHandler{
        syncService: syncService,
        connections: make(map[int64]*websocket.Conn),
    }
}

// HandleWebSocket gerencia conexão WebSocket
func (h *SyncHandler) HandleWebSocket(w http.ResponseWriter, r *http.Request) {
    // Obter userID do contexto
    userID := r.Context().Value("userID").(int64)
    
    // Upgrade para WebSocket
    conn, err := upgrader.Upgrade(w, r, nil)
    if err != nil {
        log.Printf("WebSocket upgrade error: %v", err)
        return
    }
    defer conn.Close()
    
    h.connections[userID] = conn
    
    // Loop de mensagens
    for {
        var msg SyncMessage
        err := conn.ReadJSON(&msg)
        if err != nil {
            log.Printf("WebSocket read error: %v", err)
            break
        }
        
        // Processar mensagem
        h.handleMessage(r.Context(), userID, &msg)
    }
    
    delete(h.connections, userID)
}

// SyncMessage representa mensagem WebSocket
type SyncMessage struct {
    Type string          `json:"type"`
    Data json.RawMessage `json:"data"`
}

// handleMessage processa mensagem recebida
func (h *SyncHandler) handleMessage(ctx context.Context, userID int64, msg *SyncMessage) {
    switch msg.Type {
    case "sync_request":
        // Processar requisição de sync
        h.handleSyncRequest(ctx, userID, msg.Data)
    case "ping":
        // Responder ping
        h.sendMessage(userID, &SyncMessage{Type: "pong"})
    }
}

// handleSyncRequest processa requisição de sincronização
func (h *SyncHandler) handleSyncRequest(ctx context.Context, userID int64, data json.RawMessage) {
    var req services.SyncRequest
    if err := json.Unmarshal(data, &req); err != nil {
        return
    }
    
    result, err := h.syncService.Sync(ctx, userID, req)
    if err != nil {
        h.sendError(userID, err.Error())
        return
    }
    
    h.sendMessage(userID, &SyncMessage{
        Type: "sync_response",
        Data: result,
    })
}

// sendMessage envia mensagem via WebSocket
func (h *SyncHandler) sendMessage(userID int64, msg *SyncMessage) {
    conn, ok := h.connections[userID]
    if !ok {
        return
    }
    
    if err := conn.WriteJSON(msg); err != nil {
        log.Printf("WebSocket write error: %v", err)
    }
}

// sendError envia erro via WebSocket
func (h *SyncHandler) sendError(userID int64, errorMsg string) {
    h.sendMessage(userID, &SyncMessage{
        Type: "error",
        Data: map[string]string{"message": errorMsg},
    })
}
```

## 21. Configuração e Migrations

### 21.1 Environment Variables e Configuração

#### 21.1.1 Configuração com Validação

**Exemplo: `internal/config/config.go`**

```go
package config

import (
    "fmt"
    "os"
    "strconv"
    "time"
)

// Config contém configuração da aplicação
type Config struct {
    // Application
    AppName     string `env:"APP_NAME" envDefault:"Anki Backend"`
    Environment string `env:"ENVIRONMENT" envDefault:"development" validate:"required,oneof=development staging production"`
    Debug       bool   `env:"DEBUG" envDefault:"true"`
    LogLevel    string `env:"LOG_LEVEL" envDefault:"INFO" validate:"oneof=DEBUG INFO WARN ERROR"`
    
    // API
    APIPort     int    `env:"API_PORT" envDefault:"8080" validate:"min=1,max=65535"`
    CORSOrigins string `env:"CORS_ORIGINS" envDefault:"http://localhost:3000"`
    
    // Database
    DatabaseURL      string        `env:"DATABASE_URL" validate:"required"`
    DatabasePoolSize int           `env:"DATABASE_POOL_SIZE" envDefault:"25" validate:"min=1,max=100"`
    DatabaseMaxIdle  int           `env:"DATABASE_MAX_IDLE" envDefault:"5" validate:"min=1"`
    DatabaseMaxLifetime time.Duration `env:"DATABASE_MAX_LIFETIME" envDefault:"5m"`
    
    // Redis
    RedisURL      string `env:"REDIS_URL" envDefault:"redis://localhost:6379"`
    RedisPassword string `env:"REDIS_PASSWORD"`
    RedisDB       int    `env:"REDIS_DB" envDefault:"0"`
    
    // JWT
    JWTSecret            string        `env:"JWT_SECRET" validate:"required,min=32"`
    JWTAlgorithm         string        `env:"JWT_ALGORITHM" envDefault:"HS256"`
    AccessTokenExpiry    time.Duration `env:"ACCESS_TOKEN_EXPIRY" envDefault:"15m"`
    RefreshTokenExpiry   time.Duration `env:"REFRESH_TOKEN_EXPIRY" envDefault:"7d"`
    
    // Pagination
    DefaultPageSize int `env:"DEFAULT_PAGE_SIZE" envDefault:"20" validate:"min=1,max=100"`
    MaxPageSize     int `env:"MAX_PAGE_SIZE" envDefault:"100" validate:"min=1,max=1000"`
    
    // Rate Limiting
    RateLimitPerMinute      int `env:"RATE_LIMIT_PER_MINUTE" envDefault:"60"`
    LoginRateLimitPerMinute int `env:"LOGIN_RATE_LIMIT_PER_MINUTE" envDefault:"5"`
    
    // External Services (Optional)
    SMTPHost     string `env:"SMTP_HOST"`
    SMTPPort     int    `env:"SMTP_PORT" envDefault:"587"`
    SMTPUser     string `env:"SMTP_USER"`
    SMTPPassword string `env:"SMTP_PASSWORD"`
    SMTPFrom     string `env:"SMTP_FROM" envDefault:"noreply@anki.com"`
    
    // S3 (Optional)
    S3Bucket string `env:"S3_BUCKET"`
    S3Region string `env:"S3_REGION" envDefault:"us-east-1"`
    S3Key    string `env:"S3_KEY"`
    S3Secret string `env:"S3_SECRET"`
    
    // Monitoring (Optional)
    SentryDSN string `env:"SENTRY_DSN"`
}

var (
    configInstance *Config
    configOnce     sync.Once
)

// Load carrega configuração de variáveis de ambiente (Singleton)
func Load() (*Config, error) {
    var err error
    configOnce.Do(func() {
        configInstance = &Config{}
        err = loadFromEnv(configInstance)
        if err != nil {
            return
        }
        err = validateConfig(configInstance)
    })
    return configInstance, err
}

// Get retorna instância de configuração (deve chamar Load() primeiro)
func Get() *Config {
    if configInstance == nil {
        panic("Config not loaded. Call Load() first.")
    }
    return configInstance
}

// loadFromEnv carrega valores de variáveis de ambiente
func loadFromEnv(cfg *Config) error {
    cfg.AppName = getEnv("APP_NAME", "Anki Backend")
    cfg.Environment = getEnv("ENVIRONMENT", "development")
    cfg.Debug = getBoolEnv("DEBUG", true)
    cfg.LogLevel = getEnv("LOG_LEVEL", "INFO")
    
    cfg.APIPort = getIntEnv("API_PORT", 8080)
    cfg.CORSOrigins = getEnv("CORS_ORIGINS", "http://localhost:3000")
    
    cfg.DatabaseURL = getEnv("DATABASE_URL", "postgres://user:pass@localhost/anki?sslmode=disable")
    cfg.DatabasePoolSize = getIntEnv("DATABASE_POOL_SIZE", 25)
    cfg.DatabaseMaxIdle = getIntEnv("DATABASE_MAX_IDLE", 5)
    cfg.DatabaseMaxLifetime = getDurationEnv("DATABASE_MAX_LIFETIME", 5*time.Minute)
    
    cfg.RedisURL = getEnv("REDIS_URL", "redis://localhost:6379")
    cfg.RedisPassword = getEnv("REDIS_PASSWORD", "")
    cfg.RedisDB = getIntEnv("REDIS_DB", 0)
    
    cfg.JWTSecret = getEnv("JWT_SECRET", "")
    cfg.JWTAlgorithm = getEnv("JWT_ALGORITHM", "HS256")
    cfg.AccessTokenExpiry = getDurationEnv("ACCESS_TOKEN_EXPIRY", 15*time.Minute)
    cfg.RefreshTokenExpiry = getDurationEnv("REFRESH_TOKEN_EXPIRY", 7*24*time.Hour)
    
    cfg.DefaultPageSize = getIntEnv("DEFAULT_PAGE_SIZE", 20)
    cfg.MaxPageSize = getIntEnv("MAX_PAGE_SIZE", 100)
    
    cfg.RateLimitPerMinute = getIntEnv("RATE_LIMIT_PER_MINUTE", 60)
    cfg.LoginRateLimitPerMinute = getIntEnv("LOGIN_RATE_LIMIT_PER_MINUTE", 5)
    
    cfg.SMTPHost = getEnv("SMTP_HOST", "")
    cfg.SMTPPort = getIntEnv("SMTP_PORT", 587)
    cfg.SMTPUser = getEnv("SMTP_USER", "")
    cfg.SMTPPassword = getEnv("SMTP_PASSWORD", "")
    cfg.SMTPFrom = getEnv("SMTP_FROM", "noreply@anki.com")
    
    cfg.S3Bucket = getEnv("S3_BUCKET", "")
    cfg.S3Region = getEnv("S3_REGION", "us-east-1")
    cfg.S3Key = getEnv("S3_KEY", "")
    cfg.S3Secret = getEnv("S3_SECRET", "")
    
    cfg.SentryDSN = getEnv("SENTRY_DSN", "")
    
    return nil
}

// validateConfig valida configuração
func validateConfig(cfg *Config) error {
    if cfg.Environment != "development" && cfg.Environment != "staging" && cfg.Environment != "production" {
        return fmt.Errorf("invalid environment: %s", cfg.Environment)
    }
    
    if cfg.DatabaseURL == "" {
        return fmt.Errorf("DATABASE_URL is required")
    }
    
    if cfg.JWTSecret == "" || len(cfg.JWTSecret) < 32 {
        return fmt.Errorf("JWT_SECRET must be at least 32 characters")
    }
    
    if cfg.APIPort < 1 || cfg.APIPort > 65535 {
        return fmt.Errorf("invalid API_PORT: %d", cfg.APIPort)
    }
    
    return nil
}

// Helper functions
func getEnv(key, defaultValue string) string {
    if value := os.Getenv(key); value != "" {
        return value
    }
    return defaultValue
}

func getIntEnv(key string, defaultValue int) int {
    if value := os.Getenv(key); value != "" {
        if intValue, err := strconv.Atoi(value); err == nil {
            return intValue
        }
    }
    return defaultValue
}

func getBoolEnv(key string, defaultValue bool) bool {
    if value := os.Getenv(key); value != "" {
        if boolValue, err := strconv.ParseBool(value); err == nil {
            return boolValue
        }
    }
    return defaultValue
}

func getDurationEnv(key string, defaultValue time.Duration) time.Duration {
    if value := os.Getenv(key); value != "" {
        if duration, err := time.ParseDuration(value); err == nil {
            return duration
        }
    }
    return defaultValue
}

// GetCORSOriginsList retorna lista de origens CORS
func (c *Config) GetCORSOriginsList() []string {
    if c.CORSOrigins == "" {
        return []string{}
    }
    // Split por vírgula e trim espaços
    origins := strings.Split(c.CORSOrigins, ",")
    result := make([]string, 0, len(origins))
    for _, origin := range origins {
        result = append(result, strings.TrimSpace(origin))
    }
    return result
}
```

#### 21.1.2 Environment-Specific Configs

**.env.example** (Commit to repository - no secrets):

```bash
# Application
APP_NAME="Anki Backend"
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=INFO

# API
API_PORT=8080
CORS_ORIGINS=http://localhost:3000,http://localhost:5173

# Database
DATABASE_URL=postgres://user:pass@localhost/anki?sslmode=disable
DATABASE_POOL_SIZE=25
DATABASE_MAX_IDLE=5
DATABASE_MAX_LIFETIME=5m

# Redis
REDIS_URL=redis://localhost:6379
REDIS_PASSWORD=
REDIS_DB=0

# JWT
JWT_SECRET=your-secret-key-change-in-production-min-32-chars
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRY=15m
REFRESH_TOKEN_EXPIRY=7d

# Pagination
DEFAULT_PAGE_SIZE=20
MAX_PAGE_SIZE=100

# Rate Limiting
RATE_LIMIT_PER_MINUTE=60
LOGIN_RATE_LIMIT_PER_MINUTE=5

# SMTP (Optional)
SMTP_HOST=
SMTP_PORT=587
SMTP_USER=
SMTP_PASSWORD=
SMTP_FROM=noreply@anki.com

# S3 (Optional)
S3_BUCKET=
S3_REGION=us-east-1
S3_KEY=
S3_SECRET=

# Monitoring (Optional)
SENTRY_DSN=
```

#### 21.1.3 Secrets Management

**Para Produção**:
- ✅ Usar AWS Secrets Manager, HashiCorp Vault, ou similar
- ✅ Nunca commitar secrets no git
- ✅ Rotacionar secrets regularmente
- ✅ Usar variáveis de ambiente injetadas pelo orquestrador (Kubernetes, Docker)

**Exemplo: Carregar secrets de AWS Secrets Manager**:

```go
import "github.com/aws/aws-sdk-go/service/secretsmanager"

func loadSecretsFromAWS(secretName string) (map[string]string, error) {
    svc := secretsmanager.New(session.New())
    result, err := svc.GetSecretValue(&secretsmanager.GetSecretValueInput{
        SecretId: aws.String(secretName),
    })
    if err != nil {
        return nil, err
    }
    
    var secrets map[string]string
    json.Unmarshal([]byte(*result.SecretString), &secrets)
    return secrets, nil
}
```

### 21.2 Database Migrations com golang-migrate

#### 21.2.1 Setup golang-migrate

**Instalação**:

```bash
# Instalar golang-migrate CLI
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Ou via Homebrew (macOS)
brew install golang-migrate
```

**Estrutura de Diretórios**:

```
backend/
├── migrations/
│   ├── 000001_initial_schema.up.sql
│   ├── 000001_initial_schema.down.sql
│   ├── 000002_add_deck_options.up.sql
│   ├── 000002_add_deck_options.down.sql
│   └── ...
```

#### 21.2.2 Criando Migrations

**Comando para criar nova migration**:

```bash
# Criar migration vazia
migrate create -ext sql -dir migrations -seq add_deck_options

# Isso cria:
# migrations/000002_add_deck_options.up.sql
# migrations/000002_add_deck_options.down.sql
```

**Exemplo: Migration Up (`000001_initial_schema.up.sql`)**:

```sql
-- Migration: Initial Schema
-- Created: 2024-01-20
-- Description: Cria schema inicial do sistema Anki

-- Extensões
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enums
CREATE TYPE card_state AS ENUM ('new', 'learn', 'review', 'relearn');
CREATE TYPE review_type AS ENUM ('learn', 'review', 'relearn', 'cram');

-- Tabelas principais
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW() NOT NULL,
    last_login_at TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE decks (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    parent_id BIGINT REFERENCES decks(id) ON DELETE SET NULL,
    options JSONB,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP,
    
    CONSTRAINT decks_user_id_name_unique UNIQUE (user_id, name) WHERE deleted_at IS NULL
);

CREATE TABLE notes (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    guid UUID NOT NULL UNIQUE,
    note_type_id BIGINT NOT NULL,
    fields JSONB NOT NULL,
    tags TEXT[],
    marked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW() NOT NULL,
    deleted_at TIMESTAMP
);

CREATE TABLE cards (
    id BIGSERIAL PRIMARY KEY,
    note_id BIGINT NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
    card_type_id INT NOT NULL,
    deck_id BIGINT NOT NULL REFERENCES decks(id) ON DELETE CASCADE,
    home_deck_id BIGINT REFERENCES decks(id),
    due BIGINT NOT NULL,
    interval INT NOT NULL DEFAULT 0,
    ease INT NOT NULL DEFAULT 2500,
    lapses INT NOT NULL DEFAULT 0,
    reps INT NOT NULL DEFAULT 0,
    state card_state NOT NULL DEFAULT 'new',
    position INT NOT NULL DEFAULT 0,
    flag INT NOT NULL DEFAULT 0,
    suspended BOOLEAN NOT NULL DEFAULT FALSE,
    buried BOOLEAN NOT NULL DEFAULT FALSE,
    stability DOUBLE PRECISION,
    difficulty DOUBLE PRECISION,
    last_review_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW() NOT NULL
);

-- Índices
CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_decks_user_id ON decks(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_decks_parent_id ON decks(parent_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_notes_user_id ON notes(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_notes_guid ON notes(guid);
CREATE INDEX idx_cards_note_id ON cards(note_id);
CREATE INDEX idx_cards_deck_id ON cards(deck_id);
CREATE INDEX idx_cards_due ON cards(due) WHERE suspended = FALSE AND buried = FALSE;
CREATE INDEX idx_cards_state ON cards(state);

-- Triggers para updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_decks_updated_at BEFORE UPDATE ON decks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notes_updated_at BEFORE UPDATE ON notes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cards_updated_at BEFORE UPDATE ON cards
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

**Exemplo: Migration Down (`000001_initial_schema.down.sql`)**:

```sql
-- Rollback: Remove schema inicial

DROP TRIGGER IF EXISTS update_cards_updated_at ON cards;
DROP TRIGGER IF EXISTS update_notes_updated_at ON notes;
DROP TRIGGER IF EXISTS update_decks_updated_at ON decks;
DROP TRIGGER IF EXISTS update_users_updated_at ON users;

DROP FUNCTION IF EXISTS update_updated_at_column();

DROP TABLE IF EXISTS cards;
DROP TABLE IF EXISTS notes;
DROP TABLE IF EXISTS decks;
DROP TABLE IF EXISTS users;

DROP TYPE IF EXISTS review_type;
DROP TYPE IF EXISTS card_state;
```

#### 21.2.3 Executando Migrations

**Comandos Básicos**:

```bash
# Aplicar todas as migrations pendentes
migrate -path migrations -database "postgres://user:pass@localhost/anki?sslmode=disable" up

# Reverter última migration
migrate -path migrations -database "postgres://user:pass@localhost/anki?sslmode=disable" down 1

# Reverter todas as migrations
migrate -path migrations -database "postgres://user:pass@localhost/anki?sslmode=disable" down

# Verificar versão atual
migrate -path migrations -database "postgres://user:pass@localhost/anki?sslmode=disable" version

# Forçar versão (usar com cuidado!)
migrate -path migrations -database "postgres://user:pass@localhost/anki?sslmode=disable" force 1
```

#### 21.2.4 Integração no Código Go

**Exemplo: `infra/persistence/migrate/migrate.go`**

```go
package migrate

import (
    "database/sql"
    "fmt"
    
    "github.com/golang-migrate/migrate/v4"
    "github.com/golang-migrate/migrate/v4/database/postgres"
    _ "github.com/golang-migrate/migrate/v4/source/file"
)

// RunMigrations executa migrations
func RunMigrations(db *sql.DB, migrationsPath string) error {
    driver, err := postgres.WithInstance(db, &postgres.Config{})
    if err != nil {
        return fmt.Errorf("failed to create postgres driver: %w", err)
    }
    
    m, err := migrate.NewWithDatabaseInstance(
        fmt.Sprintf("file://%s", migrationsPath),
        "postgres",
        driver,
    )
    if err != nil {
        return fmt.Errorf("failed to create migrate instance: %w", err)
    }
    
    // Aplicar todas as migrations pendentes
    if err := m.Up(); err != nil {
        if err == migrate.ErrNoChange {
            // Nenhuma migration pendente - OK
            return nil
        }
        return fmt.Errorf("failed to run migrations: %w", err)
    }
    
    return nil
}

// GetVersion retorna versão atual do banco
func GetVersion(db *sql.DB) (uint, bool, error) {
    driver, err := postgres.WithInstance(db, &postgres.Config{})
    if err != nil {
        return 0, false, err
    }
    
    m, err := migrate.NewWithDatabaseInstance(
        "file://migrations",
        "postgres",
        driver,
    )
    if err != nil {
        return 0, false, err
    }
    
    version, dirty, err := m.Version()
    return version, dirty, err
}
```

**Uso no `main.go`**:

```go
package main

import (
    "database/sql"
    "log"
    
    _ "github.com/lib/pq"
    "github.com/anki/infra/persistence/migrate"
)

func main() {
    // Conectar ao banco
    db, err := sql.Open("postgres", databaseURL)
    if err != nil {
        log.Fatal(err)
    }
    defer db.Close()
    
    // Executar migrations
    if err := migrate.RunMigrations(db, "migrations"); err != nil {
        log.Fatalf("Migration failed: %v", err)
    }
    
    // ... resto da aplicação
}
```

#### 21.2.5 Migration Best Practices

**1. Sempre Criar Migration Down**:

```sql
-- ✅ GOOD: Migration reversível
-- up.sql
ALTER TABLE cards ADD COLUMN new_field VARCHAR(255);

-- down.sql
ALTER TABLE cards DROP COLUMN new_field;
```

**2. Usar Transações para Migrations Complexas**:

```sql
-- ✅ GOOD: Migration com transação
BEGIN;

ALTER TABLE cards ADD COLUMN stability DOUBLE PRECISION;
UPDATE cards SET stability = 1.0 WHERE stability IS NULL;
ALTER TABLE cards ALTER COLUMN stability SET NOT NULL;

COMMIT;
```

**3. Versionamento de Migrations**:

```bash
# Usar sequência numérica
000001_initial_schema.up.sql
000002_add_deck_options.up.sql
000003_add_shared_decks.up.sql

# Ou usar timestamp
20240120_143000_initial_schema.up.sql
20240121_100000_add_deck_options.up.sql
```

**4. Testar Migrations em Ambiente de Desenvolvimento**:

```bash
# Sempre testar up e down
migrate up
migrate down 1
migrate up
```

#### 21.2.6 CI/CD Integration

**Exemplo: `.github/workflows/migrate.yml`**:

```yaml
name: Run Migrations

on:
  push:
    branches: [main]

jobs:
  migrate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup PostgreSQL
        run: |
          docker run -d \
            -e POSTGRES_PASSWORD=postgres \
            -e POSTGRES_DB=anki_test \
            -p 5432:5432 \
            postgres:15
      
      - name: Install golang-migrate
        run: |
          curl -L https://github.com/golang-migrate/migrate/releases/download/v4.16.2/migrate.linux-amd64.tar.gz | tar xvz
          sudo mv migrate /usr/local/bin/migrate
      
      - name: Run migrations
        run: |
          migrate -path migrations \
            -database "postgres://postgres:postgres@localhost:5432/anki_test?sslmode=disable" \
            up
```

## 22. Filter Pattern (Padrão de Filtros)

### 22.1 BaseFilter (Filtro Base)

O **Filter Pattern** permite queries flexíveis com busca, paginação e ordenação de forma reutilizável.

**Exemplo: `pkg/filters/base_filter.go`**

```go
package filters

// BaseFilter contém funcionalidades comuns de filtros
type BaseFilter struct {
    // Busca geral
    Search string `json:"search,omitempty"`
    
    // Paginação (opção 1: page/page_size)
    Page     int `json:"page,omitempty"`
    PageSize int `json:"page_size,omitempty"`
    
    // Paginação (opção 2: offset/limit)
    Offset int `json:"offset,omitempty"`
    Limit  int `json:"limit,omitempty"`
    
    // Ordenação
    SortBy    string `json:"sort_by,omitempty"`    // Campo para ordenar
    SortOrder string `json:"sort_order,omitempty"` // "asc" ou "desc"
}

// GetLimit retorna o limit calculado (prioriza limit, depois page_size)
func (f *BaseFilter) GetLimit() int {
    if f.Limit > 0 {
        return f.Limit
    }
    if f.PageSize > 0 {
        return f.PageSize
    }
    return 20 // Default
}

// GetOffset retorna o offset calculado (prioriza offset, depois page)
func (f *BaseFilter) GetOffset() int {
    if f.Offset > 0 {
        return f.Offset
    }
    if f.Page > 0 {
        return (f.Page - 1) * f.GetLimit()
    }
    return 0
}

// GetSortOrder retorna "ASC" ou "DESC"
func (f *BaseFilter) GetSortOrder() string {
    if f.SortOrder == "desc" {
        return "DESC"
    }
    return "ASC"
}
```

### 22.2 Entity-Specific Filters

Cada entidade pode estender BaseFilter com filtros específicos.

**Exemplo: `core/services/filters/deck_filter.go`**

```go
package filters

import "github.com/anki/pkg/filters"

// DeckFilter contém filtros específicos para decks
type DeckFilter struct {
    filters.BaseFilter
    
    // Filtros específicos
    UserID   *int64 `json:"user_id,omitempty"`
    ParentID *int64 `json:"parent_id,omitempty"`
    Name     string `json:"name,omitempty"`
    IsRoot   *bool  `json:"is_root,omitempty"`
}

// CardFilter contém filtros específicos para cards
type CardFilter struct {
    filters.BaseFilter
    
    // Filtros específicos
    DeckID    *int64 `json:"deck_id,omitempty"`
    NoteID    *int64 `json:"note_id,omitempty"`
    State     string `json:"state,omitempty"`     // "new", "learn", "review", "relearn"
    IsDue     *bool  `json:"is_due,omitempty"`
    Suspended *bool  `json:"suspended,omitempty"`
    Buried    *bool  `json:"buried,omitempty"`
    Flag      *int   `json:"flag,omitempty"`
}
```

### 22.3 Uso no Repository

**Exemplo: `infra/persistence/postgres/deck_repository.go`**

```go
func (r *DeckRepository) FindAll(ctx context.Context, filter *filters.DeckFilter) ([]*entities.Deck, error) {
    query := `SELECT id, user_id, name, parent_id, options, created_at, updated_at, deleted_at 
              FROM decks WHERE deleted_at IS NULL`
    
    args := []interface{}{}
    argPos := 1
    
    // Aplicar filtros específicos
    if filter.UserID != nil {
        query += fmt.Sprintf(" AND user_id = $%d", argPos)
        args = append(args, *filter.UserID)
        argPos++
    }
    
    if filter.ParentID != nil {
        query += fmt.Sprintf(" AND parent_id = $%d", argPos)
        args = append(args, *filter.ParentID)
        argPos++
    }
    
    if filter.Name != "" {
        query += fmt.Sprintf(" AND name ILIKE $%d", argPos)
        args = append(args, "%"+filter.Name+"%")
        argPos++
    }
    
    // Aplicar busca geral (do BaseFilter)
    if filter.Search != "" {
        query += fmt.Sprintf(" AND (name ILIKE $%d OR id::text ILIKE $%d)", argPos, argPos)
        args = append(args, "%"+filter.Search+"%")
        argPos++
    }
    
    // Aplicar ordenação (do BaseFilter)
    if filter.SortBy != "" {
        query += fmt.Sprintf(" ORDER BY %s %s", filter.SortBy, filter.GetSortOrder())
    } else {
        query += " ORDER BY name ASC"
    }
    
    // Aplicar paginação (do BaseFilter)
    query += fmt.Sprintf(" LIMIT $%d OFFSET $%d", argPos, argPos+1)
    args = append(args, filter.GetLimit(), filter.GetOffset())
    
    rows, err := r.db.QueryContext(ctx, query, args...)
    if err != nil {
        return nil, err
    }
    defer rows.Close()
    
    var decks []*entities.Deck
    for rows.Next() {
        deck := &entities.Deck{}
        // ... scan rows
        decks = append(decks, deck)
    }
    
    return decks, nil
}

// Count retorna total de registros (sem paginação)
func (r *DeckRepository) Count(ctx context.Context, filter *filters.DeckFilter) (int, error) {
    query := `SELECT COUNT(*) FROM decks WHERE deleted_at IS NULL`
    
    args := []interface{}{}
    argPos := 1
    
    // Aplicar mesmos filtros (sem paginação/ordenação)
    if filter.UserID != nil {
        query += fmt.Sprintf(" AND user_id = $%d", argPos)
        args = append(args, *filter.UserID)
        argPos++
    }
    
    // ... outros filtros
    
    var count int
    err := r.db.QueryRowContext(ctx, query, args...).Scan(&count)
    return count, err
}
```

### 22.4 Uso no Service

**Exemplo: `core/services/services/deck_service.go`**

```go
func (s *DeckService) ListDecks(ctx context.Context, filter *filters.DeckFilter) ([]*entities.Deck, int, error) {
    // Service apenas delega para repository - repository aplica todos os filtros
    decks, err := s.repo.FindAll(ctx, filter)
    if err != nil {
        return nil, 0, err
    }
    
    // Contar total (para paginação metadata)
    total, err := s.repo.Count(ctx, filter)
    if err != nil {
        return nil, 0, err
    }
    
    return decks, total, nil
}
```

### 22.5 Uso no Handler

**Exemplo: `app/api/http/handlers/deck_handler.go`**

```go
func (h *DeckHandler) ListDecks(w http.ResponseWriter, r *http.Request) {
    // Parse query parameters
    filter := &filters.DeckFilter{
        BaseFilter: filters.BaseFilter{
            Search:    r.URL.Query().Get("search"),
            Page:      parseInt(r.URL.Query().Get("page"), 1),
            PageSize:  parseInt(r.URL.Query().Get("page_size"), 20),
            SortBy:    r.URL.Query().Get("sort_by"),
            SortOrder: r.URL.Query().Get("sort_order"),
        },
    }
    
    if userID := r.URL.Query().Get("user_id"); userID != "" {
        id := parseInt64(userID)
        filter.UserID = &id
    }
    
    // Chamar service
    decks, total, err := h.service.ListDecks(r.Context(), filter)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    
    // Criar resposta paginada
    response := pagination.NewPaginatedResponse(
        decks,
        filter.Page,
        filter.PageSize,
        total,
    )
    
    json.NewEncoder(w).Encode(response)
}
```

## 23. Validação e Paginação

### 23.1 Validação

**Exemplo: `pkg/validator/validator.go`**

```go
package validator

import (
    "errors"
    "reflect"
    "strings"
)

// Validator valida structs
type Validator struct{}

// NewValidator cria um novo Validator
func NewValidator() *Validator {
    return &Validator{}
}

// Validate valida uma struct baseado em tags
func (v *Validator) Validate(s interface{}) error {
    val := reflect.ValueOf(s)
    if val.Kind() == reflect.Ptr {
        val = val.Elem()
    }
    
    typ := val.Type()
    
    for i := 0; i < val.NumField(); i++ {
        field := val.Field(i)
        fieldType := typ.Field(i)
        
        // Validar tag "required"
        if strings.Contains(fieldType.Tag.Get("validate"), "required") {
            if field.IsZero() {
                return errors.New(fieldType.Name + " is required")
            }
        }
        
        // Validar tag "email"
        if strings.Contains(fieldType.Tag.Get("validate"), "email") {
            if !isValidEmail(field.String()) {
                return errors.New(fieldType.Name + " must be a valid email")
            }
        }
    }
    
    return nil
}

func isValidEmail(email string) bool {
    return strings.Contains(email, "@") && strings.Contains(email, ".")
}
```

### 23.2 Paginação com Metadata Completa

**Exemplo: `pkg/pagination/paginated_response.go`**

```go
package pagination

// PaginatedResponse contém resposta paginada com metadata completa
type PaginatedResponse struct {
    Data       interface{} `json:"data"`
    Pagination Pagination  `json:"pagination"`
}

// Pagination contém metadata de paginação
type Pagination struct {
    Page       int  `json:"page"`
    PageSize   int  `json:"page_size"`
    TotalItems int  `json:"total_items"`
    TotalPages int  `json:"total_pages"`
    HasNext    bool `json:"has_next"`
    HasPrev    bool `json:"has_prev"`
}

// NewPaginatedResponse cria resposta paginada
func NewPaginatedResponse(data interface{}, page, pageSize, totalItems int) *PaginatedResponse {
    totalPages := (totalItems + pageSize - 1) / pageSize
    if totalPages == 0 {
        totalPages = 1
    }
    
    return &PaginatedResponse{
        Data: data,
        Pagination: Pagination{
            Page:       page,
            PageSize:   pageSize,
            TotalItems: totalItems,
            TotalPages: totalPages,
            HasNext:    page < totalPages,
            HasPrev:    page > 1,
        },
    }
}
```

**Exemplo: `pkg/pagination/pagination.go`**

```go
package pagination

// PageRequest contém parâmetros de paginação
type PageRequest struct {
    Page     int
    PageSize int
}

// PageResponse contém resultado paginado
type PageResponse struct {
    Data       interface{} `json:"data"`
    Page       int         `json:"page"`
    PageSize   int         `json:"page_size"`
    TotalPages int         `json:"total_pages"`
    TotalItems int         `json:"total_items"`
}

// NewPageRequest cria um novo PageRequest
func NewPageRequest(page, pageSize int) *PageRequest {
    if page < 1 {
        page = 1
    }
    if pageSize < 1 {
        pageSize = 20
    }
    if pageSize > 100 {
        pageSize = 100
    }
    
    return &PageRequest{
        Page:     page,
        PageSize: pageSize,
    }
}

// Offset calcula offset para SQL
func (p *PageRequest) Offset() int {
    return (p.Page - 1) * p.PageSize
}

// Limit retorna limit
func (p *PageRequest) Limit() int {
    return p.PageSize
}

// NewPageResponse cria um novo PageResponse
func NewPageResponse(data interface{}, page, pageSize, totalItems int) *PageResponse {
    totalPages := (totalItems + pageSize - 1) / pageSize
    
    return &PageResponse{
        Data:       data,
        Page:       page,
        PageSize:   pageSize,
        TotalPages: totalPages,
        TotalItems: totalItems,
    }
}
```

## 24. Multiple Repository Adapters (Múltiplos Adaptadores)

### 24.1 Conceito: Uma Interface, Múltiplas Implementações

Um dos **principais benefícios da Arquitetura Hexagonal** é a capacidade de ter **múltiplas implementações** da mesma interface de repositório. O **domínio não sabe** qual adaptador está sendo usado.

```
┌─────────────────────────────────────────────────────────┐
│              CORE DOMAIN (Business Logic)                │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  CardRepository (Interface)                      │  │
│  │  - FindAll(filter)                               │  │
│  │  - FindByID(id)                                  │  │
│  │  - Save(card)                                    │  │
│  │  - Delete(id)                                    │  │
│  │  - Count(filter)                                 │  │
│  └──────────────────────────────────────────────────┘  │
│                        ↑                                 │
└────────────────────────┼─────────────────────────────────┘
                         │
                         │ Dependency Inversion
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ↓                ↓                ↓
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│ PostgreSQL    │ │ Redis         │ │ In-Memory     │
│ Repository    │ │ Repository    │ │ Repository    │
│ (Production)  │ │ (Cache)       │ │ (Testing)     │
└───────────────┘ └───────────────┘ └───────────────┘
```

**Benefícios**:
- ✅ **Flexibilidade**: Troque o banco de dados sem alterar o domínio
- ✅ **Testabilidade**: Use in-memory repository para testes
- ✅ **Performance**: Use Redis para cache de dados frequentes
- ✅ **Polyglot Persistence**: PostgreSQL para dados relacionais, Redis para cache

### 24.2 PostgreSQL Repository (Produção)

**Exemplo: `infra/persistence/postgres/card_repository.go`**

```go
package postgres

import (
    "context"
    "database/sql"
    
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/repositories"
    "github.com/anki/core/services/filters"
    "github.com/anki/infra/persistence/postgres/mappers"
)

// CardRepository implementa CardRepository usando PostgreSQL
type CardRepository struct {
    db *sql.DB
}

// NewCardRepository cria novo repositório PostgreSQL
func NewCardRepository(db *sql.DB) secondary.ICardRepository {
    return &CardRepository{db: db}
}

func (r *CardRepository) FindAll(ctx context.Context, filter *filters.CardFilter) ([]*entities.Card, error) {
    // Implementação PostgreSQL com queries SQL otimizadas
    query := `SELECT id, note_id, card_type_id, deck_id, due, interval, ease, 
                     lapses, reps, state, position, flag, suspended, buried,
                     stability, difficulty, last_review_at, created_at, updated_at
              FROM cards WHERE 1=1`
    
    args := []interface{}{}
    argPos := 1
    
    if filter.DeckID != nil {
        query += fmt.Sprintf(" AND deck_id = $%d", argPos)
        args = append(args, *filter.DeckID)
        argPos++
    }
    
    // ... aplicar outros filtros
    
    // Aplicar paginação
    query += fmt.Sprintf(" LIMIT $%d OFFSET $%d", argPos, argPos+1)
    args = append(args, filter.GetLimit(), filter.GetOffset())
    
    rows, err := r.db.QueryContext(ctx, query, args...)
    if err != nil {
        return nil, err
    }
    defer rows.Close()
    
    var cards []*entities.Card
    for rows.Next() {
        card := &entities.Card{}
        // Scan usando mapper
        if err := mappers.ScanCard(rows, card); err != nil {
            return nil, err
        }
        cards = append(cards, card)
    }
    
    return cards, nil
}

func (r *CardRepository) Save(ctx context.Context, card *entities.Card) error {
    if card.ID == 0 {
        // Insert
        query := `INSERT INTO cards (...) VALUES (...) RETURNING id`
        return r.db.QueryRowContext(ctx, query, ...).Scan(&card.ID)
    } else {
        // Update
        query := `UPDATE cards SET ... WHERE id = $1`
        _, err := r.db.ExecContext(ctx, query, card.ID, ...)
        return err
    }
}
```

### 24.3 Redis Repository (Cache)

**Exemplo: `infra/cache/redis/card_repository.go`**

```go
package redis

import (
    "context"
    "encoding/json"
    "fmt"
    "time"
    
    "github.com/redis/go-redis/v9"
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/repositories"
    "github.com/anki/core/services/filters"
)

// CardRepository implementa CardRepository usando Redis (cache)
type CardRepository struct {
    client *redis.Client
    ttl    time.Duration
}

// NewCardRepository cria novo repositório Redis
func NewCardRepository(client *redis.Client, ttl time.Duration) secondary.ICardRepository {
    return &CardRepository{
        client: client,
        ttl:    ttl,
    }
}

func (r *CardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    key := fmt.Sprintf("card:%d", id)
    
    data, err := r.client.Get(ctx, key).Result()
    if err == redis.Nil {
        return nil, nil // Not found
    }
    if err != nil {
        return nil, err
    }
    
    var card entities.Card
    if err := json.Unmarshal([]byte(data), &card); err != nil {
        return nil, err
    }
    
    return &card, nil
}

func (r *CardRepository) Save(ctx context.Context, card *entities.Card) error {
    key := fmt.Sprintf("card:%d", card.ID)
    
    data, err := json.Marshal(card)
    if err != nil {
        return err
    }
    
    return r.client.Set(ctx, key, data, r.ttl).Err()
}

// FindAll - Redis não suporta queries complexas, apenas cache simples
func (r *CardRepository) FindAll(ctx context.Context, filter *filters.CardFilter) ([]*entities.Card, error) {
    // Redis não é ideal para queries complexas
    // Usar apenas para cache de resultados específicos
    return nil, fmt.Errorf("Redis repository não suporta FindAll com filtros complexos")
}
```

**Quando usar Redis Repository**:
- ✅ Cache layer sobre PostgreSQL (read-through cache)
- ✅ Session storage (sessões de usuário, tokens)
- ✅ Dados temporários com TTL (OTP codes, reset tokens)
- ✅ Rate limiting (tentativas de login, chamadas de API)

### 24.4 In-Memory Repository (Testes)

**Exemplo: `tests/repositories/in_memory_card_repository.go`**

```go
package repositories

import (
    "context"
    "sync"
    
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/repositories"
    "github.com/anki/core/services/filters"
)

// InMemoryCardRepository implementa CardRepository em memória (para testes)
type InMemoryCardRepository struct {
    mu    sync.RWMutex
    cards map[int64]*entities.Card
    nextID int64
}

// NewInMemoryCardRepository cria novo repositório em memória
func NewInMemoryCardRepository() secondary.ICardRepository {
    return &InMemoryCardRepository{
        cards: make(map[int64]*entities.Card),
        nextID: 1,
    }
}

func (r *InMemoryCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    r.mu.RLock()
    defer r.mu.RUnlock()
    
    card, exists := r.cards[id]
    if !exists {
        return nil, nil
    }
    
    return card, nil
}

func (r *InMemoryCardRepository) FindAll(ctx context.Context, filter *filters.CardFilter) ([]*entities.Card, error) {
    r.mu.RLock()
    defer r.mu.RUnlock()
    
    var results []*entities.Card
    for _, card := range r.cards {
        // Aplicar filtros em memória
        if filter.DeckID != nil && card.DeckID != *filter.DeckID {
            continue
        }
        if filter.State != "" && string(card.State) != filter.State {
            continue
        }
        
        results = append(results, card)
    }
    
    return results, nil
}

func (r *InMemoryCardRepository) Save(ctx context.Context, card *entities.Card) error {
    r.mu.Lock()
    defer r.mu.Unlock()
    
    if card.ID == 0 {
        card.ID = r.nextID
        r.nextID++
    }
    
    // Deep copy para evitar race conditions
    cardCopy := *card
    r.cards[card.ID] = &cardCopy
    
    return nil
}

func (r *InMemoryCardRepository) Delete(ctx context.Context, id int64) error {
    r.mu.Lock()
    defer r.mu.Unlock()
    
    delete(r.cards, id)
    return nil
}

func (r *InMemoryCardRepository) Count(ctx context.Context, filter *filters.CardFilter) (int, error) {
    cards, err := r.FindAll(ctx, filter)
    if err != nil {
        return 0, err
    }
    return len(cards), nil
}
```

### 24.5 Composite Repository (Cache + Database)

**Exemplo: `infra/persistence/composite/card_repository.go`**

```go
package composite

import (
    "context"
    
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/repositories"
    "github.com/anki/core/services/filters"
)

// CompositeCardRepository combina cache (Redis) + database (PostgreSQL)
type CompositeCardRepository struct {
    cache    secondary.ICardRepository // Redis
    database secondary.ICardRepository // PostgreSQL
}

// NewCompositeCardRepository cria repositório composto
func NewCompositeCardRepository(
    cache secondary.ICardRepository,
    database secondary.ICardRepository,
) secondary.ICardRepository {
    return &CompositeCardRepository{
        cache:    cache,
        database: database,
    }
}

func (r *CompositeCardRepository) FindByID(ctx context.Context, id int64) (*entities.Card, error) {
    // 1. Tentar cache primeiro
    card, err := r.cache.FindByID(ctx, id)
    if err == nil && card != nil {
        return card, nil // Cache hit
    }
    
    // 2. Cache miss - buscar no database
    card, err = r.database.FindByID(ctx, id)
    if err != nil {
        return nil, err
    }
    
    // 3. Popular cache para próxima vez
    if card != nil {
        r.cache.Save(ctx, card) // Ignorar erro de cache
    }
    
    return card, nil
}

func (r *CompositeCardRepository) Save(ctx context.Context, card *entities.Card) error {
    // 1. Salvar no database
    if err := r.database.Save(ctx, card); err != nil {
        return err
    }
    
    // 2. Atualizar cache
    r.cache.Save(ctx, card) // Ignorar erro de cache
    
    return nil
}

func (r *CompositeCardRepository) FindAll(ctx context.Context, filter *filters.CardFilter) ([]*entities.Card, error) {
    // Para queries complexas, sempre usar database
    return r.database.FindAll(ctx, filter)
}
```

### 24.6 Factory Pattern para Seleção de Repository

**Exemplo: `infra/persistence/factory/repository_factory.go`**

```go
package factory

import (
    "database/sql"
    
    "github.com/redis/go-redis/v9"
    "github.com/anki/core/domain/repositories"
    "github.com/anki/infra/persistence/postgres"
    "github.com/anki/infra/cache/redis"
    "github.com/anki/infra/persistence/composite"
    "github.com/anki/tests/repositories"
)

// RepositoryType define tipo de repositório
type RepositoryType string

const (
    RepositoryTypePostgreSQL RepositoryType = "postgresql"
    RepositoryTypeRedis      RepositoryType = "redis"
    RepositoryTypeInMemory   RepositoryType = "in_memory"
    RepositoryTypeComposite  RepositoryType = "composite"
)

// RepositoryFactory cria repositórios baseado em configuração
type RepositoryFactory struct {
    db          *sql.DB
    redisClient *redis.Client
    useCache    bool
}

// NewRepositoryFactory cria nova factory
func NewRepositoryFactory(db *sql.DB, redisClient *redis.Client, useCache bool) *RepositoryFactory {
    return &RepositoryFactory{
        db:          db,
        redisClient: redisClient,
        useCache:    useCache,
    }
}

// CreateCardRepository cria CardRepository baseado em configuração
func (f *RepositoryFactory) CreateCardRepository() secondary.ICardRepository {
    if f.useCache && f.redisClient != nil {
        // Composite: Cache + Database
        cacheRepo := redis.NewCardRepository(f.redisClient, 1*time.Hour)
        dbRepo := postgres.NewCardRepository(f.db)
        return composite.NewCompositeCardRepository(cacheRepo, dbRepo)
    }
    
    // Apenas Database
    return postgres.NewCardRepository(f.db)
}

// CreateCardRepositoryForTesting cria repositório in-memory para testes
func CreateCardRepositoryForTesting() secondary.ICardRepository {
    return repositories.NewInMemoryCardRepository()
}
```

## 25. Application Services Adicionais

### 23.1 ImportService (Importação)

**Exemplo: `core/services/services/import_service.go`**

```go
package services

import (
    "context"
    "encoding/csv"
    "io"
    "time"
    
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/repositories"
    "github.com/anki/core/domain/valueobjects"
    "github.com/anki/infra/storage"
)

// ImportService orquestra importação de dados
type ImportService struct {
    noteRepo     repositories.NoteRepository
    cardRepo     secondary.ICardRepository
    deckRepo     repositories.DeckRepository
    mediaRepo    repositories.MediaRepository
    storage      storage.Storage
}

// NewImportService cria um novo ImportService
func NewImportService(
    noteRepo repositories.NoteRepository,
    cardRepo secondary.ICardRepository,
    deckRepo repositories.DeckRepository,
    mediaRepo repositories.MediaRepository,
    storage storage.Storage,
) *ImportService {
    return &ImportService{
        noteRepo:  noteRepo,
        cardRepo:  cardRepo,
        deckRepo:  deckRepo,
        mediaRepo: mediaRepo,
        storage:   storage,
    }
}

// ImportTextRequest contém dados para importação de texto
type ImportTextRequest struct {
    Reader      io.Reader
    Format      string // "csv", "tsv"
    NoteTypeID  int64
    DeckID      int64
    Mapping     map[string]int // campo -> índice da coluna
    DuplicateAction string // "ignore", "update", "create"
}

// ImportTextResult contém resultado da importação
type ImportTextResult struct {
    Imported int
    Updated  int
    Skipped  int
    Errors   []string
}

// ImportText importa notes de arquivo de texto
func (s *ImportService) ImportText(
    ctx context.Context,
    userID int64,
    req ImportTextRequest,
) (*ImportTextResult, error) {
    result := &ImportTextResult{}
    
    reader := csv.NewReader(req.Reader)
    if req.Format == "tsv" {
        reader.Comma = '\t'
    }
    
    // Ler header
    header, err := reader.Read()
    if err != nil {
        return nil, err
    }
    
    // Processar linhas
    for {
        record, err := reader.Read()
        if err == io.EOF {
            break
        }
        if err != nil {
            result.Errors = append(result.Errors, err.Error())
            continue
        }
        
        // Criar note a partir do record
        note, err := s.createNoteFromRecord(ctx, userID, req, header, record)
        if err != nil {
            result.Errors = append(result.Errors, err.Error())
            continue
        }
        
        // Verificar duplicatas
        if req.DuplicateAction != "create" {
            duplicates, _ := s.noteRepo.FindDuplicates(ctx, userID, req.NoteTypeID, note.GetFirstField())
            if len(duplicates) > 0 {
                if req.DuplicateAction == "ignore" {
                    result.Skipped++
                    continue
                } else if req.DuplicateAction == "update" {
                    // Atualizar note existente
                    existing := duplicates[0]
                    existing.Fields = note.Fields
                    s.noteRepo.Save(ctx, existing)
                    result.Updated++
                    continue
                }
            }
        }
        
        // Criar nova note
        s.noteRepo.Save(ctx, note)
        result.Imported++
    }
    
    return result, nil
}

// ImportPackageRequest contém dados para importação de package
type ImportPackageRequest struct {
    Reader io.Reader
    Format string // "apkg", "colpkg"
}

// ImportPackageResult contém resultado da importação
type ImportPackageResult struct {
    Decks    int
    Notes    int
    Cards    int
    Media    int
    Errors   []string
}

// ImportPackage importa package (.apkg ou .colpkg)
func (s *ImportService) ImportPackage(
    ctx context.Context,
    userID int64,
    req ImportPackageRequest,
) (*ImportPackageResult, error) {
    // Implementação de parsing de .apkg/.colpkg
    // Formato é um arquivo ZIP com SQLite database e media files
    return &ImportPackageResult{}, nil
}

func (s *ImportService) createNoteFromRecord(
    ctx context.Context,
    userID int64,
    req ImportTextRequest,
    header []string,
    record []string,
) (*entities.Note, error) {
    fields := make(map[string]string)
    
    for fieldName, colIndex := range req.Mapping {
        if colIndex < len(record) {
            fields[fieldName] = record[colIndex]
        }
    }
    
    note := &entities.Note{
        UserID:     userID,
        NoteTypeID: req.NoteTypeID,
        Fields:     fields,
        CreatedAt:  time.Now(),
        UpdatedAt:  time.Now(),
    }
    
    // Gerar GUID
    guid, err := valueobjects.NewGUID()
    if err != nil {
        return nil, err
    }
    note.GUID = guid
    
    return note, nil
}
```

### 23.2 ExportService (Exportação)

**Exemplo: `core/services/services/export_service.go`**

```go
package services

import (
    "context"
    "io"
    
    "github.com/anki/core/domain/repositories"
    "github.com/anki/infra/storage"
)

// ExportService orquestra exportação de dados
type ExportService struct {
    noteRepo  repositories.NoteRepository
    cardRepo  secondary.ICardRepository
    deckRepo  repositories.DeckRepository
    mediaRepo repositories.MediaRepository
    storage   storage.Storage
}

// NewExportService cria um novo ExportService
func NewExportService(
    noteRepo repositories.NoteRepository,
    cardRepo secondary.ICardRepository,
    deckRepo repositories.DeckRepository,
    mediaRepo repositories.MediaRepository,
    storage storage.Storage,
) *ExportService {
    return &ExportService{
        noteRepo:  noteRepo,
        cardRepo:  cardRepo,
        deckRepo:  deckRepo,
        mediaRepo: mediaRepo,
        storage:   storage,
    }
}

// ExportDeckRequest contém dados para exportação
type ExportDeckRequest struct {
    DeckID           int64
    Format           string // "apkg", "text"
    IncludeScheduling bool
    IncludeMedia     bool
    ForSharing       bool // Remove leech tags, marked, etc.
}

// ExportDeck exporta deck como package ou texto
func (s *ExportService) ExportDeck(
    ctx context.Context,
    userID int64,
    req ExportDeckRequest,
) (io.Reader, error) {
    if req.Format == "apkg" {
        return s.exportAsPackage(ctx, userID, req)
    }
    return s.exportAsText(ctx, userID, req)
}

// exportAsPackage exporta como .apkg
func (s *ExportService) exportAsPackage(
    ctx context.Context,
    userID int64,
    req ExportDeckRequest,
) (io.Reader, error) {
    // Criar arquivo ZIP
    // Adicionar SQLite database com dados do deck
    // Adicionar media files se IncludeMedia
    // Retornar reader do ZIP
    return nil, nil
}

// exportAsText exporta como texto
func (s *ExportService) exportAsText(
    ctx context.Context,
    userID int64,
    req ExportDeckRequest,
) (io.Reader, error) {
    // Exportar notes como CSV/TSV
    return nil, nil
}

// ExportCollection exporta coleção completa como .colpkg
func (s *ExportService) ExportCollection(
    ctx context.Context,
    userID int64,
    includeMedia bool,
) (io.Reader, error) {
    // Similar ao exportAsPackage mas para toda a coleção
    return nil, nil
}
```

### 23.3 BackupService (Backups)

**Exemplo: `core/services/services/backup_service.go`**

```go
package services

import (
    "context"
    "fmt"
    "time"
    
    "github.com/anki/core/domain/repositories"
    "github.com/anki/infra/storage"
)

// BackupService orquestra backups
type BackupService struct {
    exportService *ExportService
    storage       storage.Storage
}

// NewBackupService cria um novo BackupService
func NewBackupService(
    exportService *ExportService,
    storage storage.Storage,
) *BackupService {
    return &BackupService{
        exportService: exportService,
        storage:       storage,
    }
}

// CreateBackupRequest contém dados para criar backup
type CreateBackupRequest struct {
    Type string // "manual", "automatic", "before_operation"
}

// CreateBackup cria um backup
func (s *BackupService) CreateBackup(
    ctx context.Context,
    userID int64,
    req CreateBackupRequest,
) (*BackupInfo, error) {
    // Exportar coleção completa
    reader, err := s.exportService.ExportCollection(ctx, userID, true)
    if err != nil {
        return nil, err
    }
    
    // Salvar no storage com timestamp
    filename := s.generateBackupFilename(userID, req.Type)
    err = s.storage.Upload(ctx, filename, reader)
    if err != nil {
        return nil, err
    }
    
    return &BackupInfo{
        Filename:  filename,
        CreatedAt: time.Now(),
        Type:      req.Type,
        Size:      0, // Calcular tamanho
    }, nil
}

// BackupInfo contém informações de backup
type BackupInfo struct {
    Filename  string
    CreatedAt time.Time
    Type      string
    Size      int64
}

// ListBackups lista backups disponíveis
func (s *BackupService) ListBackups(
    ctx context.Context,
    userID int64,
) ([]*BackupInfo, error) {
    // Listar arquivos de backup do storage
    return []*BackupInfo{}, nil
}

// RestoreBackup restaura um backup
func (s *BackupService) RestoreBackup(
    ctx context.Context,
    userID int64,
    filename string,
) error {
    // Criar backup antes de restaurar
    s.CreateBackup(ctx, userID, CreateBackupRequest{Type: "before_restore"})
    
    // Fazer download do backup
    reader, err := s.storage.Download(ctx, filename)
    if err != nil {
        return err
    }
    defer reader.Close()
    
    // Importar package
    // importService.ImportPackage(...)
    
    return nil
}

// CleanupOldBackups remove backups antigos
func (s *BackupService) CleanupOldBackups(
    ctx context.Context,
    userID int64,
    keepDaily, keepWeekly, keepMonthly int,
) error {
    // Implementar lógica de limpeza
    return nil
}

func (s *BackupService) generateBackupFilename(userID int64, backupType string) string {
    timestamp := time.Now().Format("20060102_150405")
    return fmt.Sprintf("backups/%d/%s_%s.colpkg", userID, backupType, timestamp)
}
```

### 23.4 BatchService (Operações em Lote)

**Exemplo: `core/services/services/batch_service.go`**

```go
package services

import (
    "context"
    
    "github.com/anki/core/domain/repositories"
)

// BatchService orquestra operações em lote
type BatchService struct {
    cardRepo secondary.ICardRepository
    noteRepo repositories.NoteRepository
}

// NewBatchService cria um novo BatchService
func NewBatchService(
    cardRepo secondary.ICardRepository,
    noteRepo repositories.NoteRepository,
) *BatchService {
    return &BatchService{
        cardRepo: cardRepo,
        noteRepo: noteRepo,
    }
}

// BatchUpdateCardsRequest contém dados para atualização em lote
type BatchUpdateCardsRequest struct {
    CardIDs []int64
    Updates map[string]interface{} // deck_id, flag, suspended, buried, etc.
}

// BatchUpdateCards atualiza múltiplos cards
func (s *BatchService) BatchUpdateCards(
    ctx context.Context,
    userID int64,
    req BatchUpdateCardsRequest,
) error {
    for _, cardID := range req.CardIDs {
        card, err := s.cardRepo.FindByID(ctx, cardID)
        if err != nil {
            continue
        }
        
        // Validar ownership
        // Aplicar updates
        if deckID, ok := req.Updates["deck_id"].(int64); ok {
            card.DeckID = deckID
        }
        if flag, ok := req.Updates["flag"].(int); ok {
            card.Flag = flag
        }
        if suspended, ok := req.Updates["suspended"].(bool); ok {
            card.Suspended = suspended
        }
        
        s.cardRepo.Save(ctx, card)
    }
    
    return nil
}

// BatchDeleteNotes exclui múltiplas notes
func (s *BatchService) BatchDeleteNotes(
    ctx context.Context,
    userID int64,
    noteIDs []int64,
) error {
    for _, noteID := range noteIDs {
        s.noteRepo.Delete(ctx, noteID)
    }
    return nil
}

// BatchChangeDeck move cards para outro deck
func (s *BatchService) BatchChangeDeck(
    ctx context.Context,
    userID int64,
    cardIDs []int64,
    newDeckID int64,
) error {
    return s.BatchUpdateCards(ctx, userID, BatchUpdateCardsRequest{
        CardIDs: cardIDs,
        Updates: map[string]interface{}{
            "deck_id": newDeckID,
        },
    })
}
```

## 24. Repositórios Adicionais

### 24.1 NoteTypeRepository

**Exemplo: `core/interfaces/secondary/note_type_repository.go`**

```go
package repositories

import (
    "context"
    "errors"
    "github.com/anki/core/domain/entities"
)

var (
    ErrNoteTypeNotFound = errors.New("note type não encontrado")
)

// NoteTypeRepository define o contrato para persistência de note types
type NoteTypeRepository interface {
    FindByID(ctx context.Context, id int64) (*entities.NoteType, error)
    FindByUserID(ctx context.Context, userID int64) ([]*entities.NoteType, error)
    FindByName(ctx context.Context, userID int64, name string) (*entities.NoteType, error)
    Save(ctx context.Context, noteType *entities.NoteType) error
    Delete(ctx context.Context, id int64) error
    Exists(ctx context.Context, userID int64, name string) (bool, error)
}
```

### 24.2 MediaRepository

**Exemplo: `core/interfaces/secondary/media_repository.go`**

```go
package repositories

import (
    "context"
    "errors"
    "github.com/anki/core/domain/entities"
)

var (
    ErrMediaNotFound = errors.New("media não encontrado")
)

// MediaRepository define o contrato para persistência de media
type MediaRepository interface {
    FindByID(ctx context.Context, id int64) (*entities.Media, error)
    FindByHash(ctx context.Context, userID int64, hash string) (*entities.Media, error)
    FindByUserID(ctx context.Context, userID int64) ([]*entities.Media, error)
    FindUnused(ctx context.Context, userID int64) ([]*entities.Media, error)
    Save(ctx context.Context, media *entities.Media) error
    Delete(ctx context.Context, id int64) error
    AssociateWithNote(ctx context.Context, noteID int64, mediaID int64, fieldName *string) error
}
```

### 24.3 FilteredDeckRepository

**Exemplo: `core/interfaces/secondary/filtered_deck_repository.go`**

```go
package repositories

import (
    "context"
    "errors"
    "github.com/anki/core/domain/entities"
)

var (
    ErrFilteredDeckNotFound = errors.New("filtered deck não encontrado")
)

// FilteredDeckRepository define o contrato para persistência de filtered decks
type FilteredDeckRepository interface {
    FindByID(ctx context.Context, id int64) (*entities.FilteredDeck, error)
    FindByUserID(ctx context.Context, userID int64) ([]*entities.FilteredDeck, error)
    Save(ctx context.Context, filteredDeck *entities.FilteredDeck) error
    Delete(ctx context.Context, id int64) error
    Rebuild(ctx context.Context, id int64) error // Reconstrói cards do filtered deck
}
```

## 25. HTTP Handlers Adicionais

### 25.1 Import/Export Handlers

**Exemplo: `app/api/http/handlers/import_handler.go`**

```go
package handlers

import (
    "encoding/json"
    "fmt"
    "io"
    "net/http"
    "strconv"
    
    "github.com/anki/core/services/services"
    "github.com/anki/pkg/errors"
)

type ImportHandler struct {
    importService *services.ImportService
}

func NewImportHandler(importService *services.ImportService) *ImportHandler {
    return &ImportHandler{importService: importService}
}

// ImportTextHandler importa notes de arquivo de texto
func (h *ImportHandler) ImportTextHandler(w http.ResponseWriter, r *http.Request) {
    userID := r.Context().Value("userID").(int64)
    
    // Parse multipart form
    err := r.ParseMultipartForm(32 << 20) // 32MB
    if err != nil {
        errors.RespondError(w, http.StatusBadRequest, "invalid form")
        return
    }
    
    file, _, err := r.FormFile("file")
    if err != nil {
        errors.RespondError(w, http.StatusBadRequest, "file required")
        return
    }
    defer file.Close()
    
    format := r.FormValue("format")
    noteTypeID := parseInt64(r.FormValue("note_type_id"))
    deckID := parseInt64(r.FormValue("deck_id"))
    
    req := services.ImportTextRequest{
        Reader:         file,
        Format:         format,
        NoteTypeID:     noteTypeID,
        DeckID:         deckID,
        DuplicateAction: r.FormValue("duplicate_action"),
    }
    
    result, err := h.importService.ImportText(r.Context(), userID, req)
    if err != nil {
        errors.RespondError(w, http.StatusInternalServerError, err.Error())
        return
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(result)
}

// ImportPackageHandler importa package (.apkg ou .colpkg)
func (h *ImportHandler) ImportPackageHandler(w http.ResponseWriter, r *http.Request) {
    userID := r.Context().Value("userID").(int64)
    
    file, _, err := r.FormFile("file")
    if err != nil {
        errors.RespondError(w, http.StatusBadRequest, "file required")
        return
    }
    defer file.Close()
    
    format := r.FormValue("format")
    
    req := services.ImportPackageRequest{
        Reader: file,
        Format: format,
    }
    
    result, err := h.importService.ImportPackage(r.Context(), userID, req)
    if err != nil {
        errors.RespondError(w, http.StatusInternalServerError, err.Error())
        return
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(result)
}
```

**Exemplo: `app/api/http/handlers/export_handler.go`**

```go
package handlers

import (
    "io"
    "net/http"
    
    "github.com/anki/core/services/services"
    "github.com/anki/pkg/errors"
)

type ExportHandler struct {
    exportService *services.ExportService
}

func NewExportHandler(exportService *services.ExportService) *ExportHandler {
    return &ExportHandler{exportService: exportService}
}

// ExportDeckHandler exporta deck
func (h *ExportHandler) ExportDeckHandler(w http.ResponseWriter, r *http.Request) {
    userID := r.Context().Value("userID").(int64)
    deckID := parseInt64(r.URL.Query().Get("deck_id"))
    
    req := services.ExportDeckRequest{
        DeckID:           deckID,
        Format:           r.URL.Query().Get("format"),
        IncludeScheduling: r.URL.Query().Get("include_scheduling") == "true",
        IncludeMedia:     r.URL.Query().Get("include_media") == "true",
        ForSharing:       r.URL.Query().Get("for_sharing") == "true",
    }
    
    reader, err := h.exportService.ExportDeck(r.Context(), userID, req)
    if err != nil {
        errors.RespondError(w, http.StatusInternalServerError, err.Error())
        return
    }
    
    filename := "deck.apkg"
    if req.Format == "text" {
        filename = "deck.txt"
    }
    
    w.Header().Set("Content-Disposition", "attachment; filename="+filename)
    w.Header().Set("Content-Type", "application/octet-stream")
    
    io.Copy(w, reader)
}

// parseInt64 converte string para int64
func parseInt64(s string) int64 {
    val, _ := strconv.ParseInt(s, 10, 64)
    return val
}
```

### 25.2 Backup Handler

**Exemplo: `app/api/http/handlers/backup_handler.go`**

```go
package handlers

import (
    "encoding/json"
    "net/http"
    
    "github.com/anki/core/services/services"
    "github.com/anki/pkg/errors"
)

type BackupHandler struct {
    backupService *services.BackupService
}

func NewBackupHandler(backupService *services.BackupService) *BackupHandler {
    return &BackupHandler{backupService: backupService}
}

// CreateBackupHandler cria um backup
func (h *BackupHandler) CreateBackupHandler(w http.ResponseWriter, r *http.Request) {
    userID := r.Context().Value("userID").(int64)
    
    var req services.CreateBackupRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        errors.RespondError(w, http.StatusBadRequest, "invalid request")
        return
    }
    
    backup, err := h.backupService.CreateBackup(r.Context(), userID, req)
    if err != nil {
        errors.RespondError(w, http.StatusInternalServerError, err.Error())
        return
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(backup)
}

// ListBackupsHandler lista backups
func (h *BackupHandler) ListBackupsHandler(w http.ResponseWriter, r *http.Request) {
    userID := r.Context().Value("userID").(int64)
    
    backups, err := h.backupService.ListBackups(r.Context(), userID)
    if err != nil {
        errors.RespondError(w, http.StatusInternalServerError, err.Error())
        return
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(backups)
}

// RestoreBackupHandler restaura um backup
func (h *BackupHandler) RestoreBackupHandler(w http.ResponseWriter, r *http.Request) {
    userID := r.Context().Value("userID").(int64)
    filename := r.URL.Query().Get("filename")
    
    if err := h.backupService.RestoreBackup(r.Context(), userID, filename); err != nil {
        errors.RespondError(w, http.StatusInternalServerError, err.Error())
        return
    }
    
    w.WriteHeader(http.StatusOK)
}
```

## 26. Funcionalidades Adicionais

### 26.1 Shared Decks Service

**Exemplo: `core/services/services/shared_deck_service.go`**

```go
package services

import (
    "context"
    "fmt"
    "io"
    "time"
    
    "github.com/anki/core/domain/entities"
    "github.com/anki/core/domain/repositories"
    "github.com/anki/infra/storage"
)

// SharedDeckService orquestra compartilhamento de decks
type SharedDeckService struct {
    sharedDeckRepo repositories.SharedDeckRepository
    exportService  *ExportService
    storage        storage.Storage
}

// NewSharedDeckService cria um novo SharedDeckService
func NewSharedDeckService(
    sharedDeckRepo repositories.SharedDeckRepository,
    exportService *ExportService,
    storage storage.Storage,
) *SharedDeckService {
    return &SharedDeckService{
        sharedDeckRepo: sharedDeckRepo,
        exportService:  exportService,
        storage:        storage,
    }
}

// ShareDeckRequest contém dados para compartilhar deck
type ShareDeckRequest struct {
    DeckID      int64
    Name        string
    Description string
    Category    string
    Tags        []string
    IsPublic    bool
}

// ShareDeck compartilha um deck publicamente
func (s *SharedDeckService) ShareDeck(
    ctx context.Context,
    userID int64,
    req ShareDeckRequest,
) (*entities.SharedDeck, error) {
    // 1. Exportar deck como .apkg
    exportReq := ExportDeckRequest{
        DeckID:       req.DeckID,
        Format:       "apkg",
        IncludeMedia: true,
        ForSharing:   true, // Remove leech tags, marked, etc.
    }
    
    reader, err := s.exportService.ExportDeck(ctx, userID, exportReq)
    if err != nil {
        return nil, err
    }
    
    // 2. Salvar package no storage
    packagePath := fmt.Sprintf("shared_decks/%d/%d_%d.apkg", userID, req.DeckID, time.Now().Unix())
    err = s.storage.Upload(ctx, packagePath, reader)
    if err != nil {
        return nil, err
    }
    
    // 3. Criar registro de shared deck
    sharedDeck := &entities.SharedDeck{
        AuthorID:    userID,
        Name:        req.Name,
        Description: req.Description,
        Category:    req.Category,
        Tags:        req.Tags,
        PackagePath: packagePath,
        IsPublic:    req.IsPublic,
        CreatedAt:   time.Now(),
        UpdatedAt:   time.Now(),
    }
    
    if err := s.sharedDeckRepo.Save(ctx, sharedDeck); err != nil {
        return nil, err
    }
    
    return sharedDeck, nil
}

// SearchSharedDecks busca decks compartilhados
func (s *SharedDeckService) SearchSharedDecks(
    ctx context.Context,
    query string,
    category string,
    tags []string,
    limit, offset int,
) ([]*entities.SharedDeck, int, error) {
    return s.sharedDeckRepo.Search(ctx, query, category, tags, limit, offset)
}

// DownloadSharedDeck incrementa contador e retorna package
func (s *SharedDeckService) DownloadSharedDeck(
    ctx context.Context,
    sharedDeckID int64,
) (io.Reader, error) {
    sharedDeck, err := s.sharedDeckRepo.FindByID(ctx, sharedDeckID)
    if err != nil {
        return nil, err
    }
    
    // Incrementar contador de downloads
    sharedDeck.DownloadCount++
    s.sharedDeckRepo.Save(ctx, sharedDeck)
    
    // Retornar package
    return s.storage.Download(ctx, sharedDeck.PackagePath)
}
```

**Exemplo: `core/domain/entities/shared_deck.go`**

```go
package entities

import (
    "time"
)

// SharedDeck representa um deck compartilhado publicamente
type SharedDeck struct {
    ID            int64
    AuthorID      int64
    Name          string
    Description   string
    Category      string
    PackagePath   string
    PackageSize   int64
    DownloadCount int
    RatingAverage float64
    RatingCount   int
    Tags          []string
    IsFeatured    bool
    IsPublic      bool
    CreatedAt     time.Time
    UpdatedAt     time.Time
    DeletedAt     *time.Time
}
```

### 26.2 LaTeX Rendering Service

**Exemplo: `core/domain/services/latex_renderer.go`**

```go
package services

import (
    "bytes"
    "context"
    "io"
)

// LaTeXRendererService renderiza LaTeX para imagens
type LaTeXRendererService interface {
    Render(ctx context.Context, latex string, dpi int) (io.Reader, error)
    RenderInline(ctx context.Context, latex string) (io.Reader, error)
}

// LaTeXRenderer implementa renderização LaTeX
type LaTeXRenderer struct {
    // Pode usar biblioteca como go-latex ou chamar serviço externo
}

// NewLaTeXRenderer cria um novo LaTeXRenderer
func NewLaTeXRenderer() *LaTeXRenderer {
    return &LaTeXRenderer{}
}

// Render renderiza LaTeX como imagem
func (r *LaTeXRenderer) Render(ctx context.Context, latex string, dpi int) (io.Reader, error) {
    // Implementação usando biblioteca LaTeX ou serviço externo
    // Retorna imagem PNG/SVG
    return bytes.NewReader([]byte{}), nil
}

// RenderInline renderiza LaTeX inline
func (r *LaTeXRenderer) RenderInline(ctx context.Context, latex string) (io.Reader, error) {
    // Similar ao Render mas com configurações inline
    return r.Render(ctx, latex, 150) // DPI menor para inline
}
```

### 26.3 Unicode Normalization Service

**Exemplo: `core/domain/services/unicode_normalizer.go`**

```go
package services

import (
    "golang.org/x/text/unicode/norm"
)

// UnicodeNormalizerService normaliza texto Unicode
type UnicodeNormalizerService interface {
    Normalize(text string) string
    NormalizeForSearch(text string) string
}

// UnicodeNormalizer implementa normalização Unicode
type UnicodeNormalizer struct {
    form norm.Form
}

// NewUnicodeNormalizer cria um novo UnicodeNormalizer
func NewUnicodeNormalizer() *UnicodeNormalizer {
    return &UnicodeNormalizer{
        form: norm.NFC, // Normalization Form Canonical Composition
    }
}

// Normalize normaliza texto para NFC
func (n *UnicodeNormalizer) Normalize(text string) string {
    return n.form.String(text)
}

// NormalizeForSearch normaliza texto para busca (remove acentos opcionalmente)
func (n *UnicodeNormalizer) NormalizeForSearch(text string) string {
    normalized := n.Normalize(text)
    // Opcionalmente remover acentos para busca mais flexível
    // return removeAccents(normalized)
    return normalized
}
```

### 26.4 Shared Deck Repository

**Exemplo: `core/interfaces/secondary/shared_deck_repository.go`**

```go
package repositories

import (
    "context"
    "errors"
    "github.com/anki/core/domain/entities"
)

var (
    ErrSharedDeckNotFound = errors.New("shared deck não encontrado")
)

// SharedDeckRepository define o contrato para persistência de shared decks
type SharedDeckRepository interface {
    FindByID(ctx context.Context, id int64) (*entities.SharedDeck, error)
    FindByAuthorID(ctx context.Context, authorID int64) ([]*entities.SharedDeck, error)
    Search(
        ctx context.Context,
        query string,
        category string,
        tags []string,
        limit, offset int,
    ) ([]*entities.SharedDeck, int, error)
    FindFeatured(ctx context.Context, limit int) ([]*entities.SharedDeck, error)
    Save(ctx context.Context, sharedDeck *entities.SharedDeck) error
    Delete(ctx context.Context, id int64) error
    Rate(ctx context.Context, sharedDeckID int64, userID int64, rating int) error
}
```

## 27. Middleware Detalhado

### 27.1 Error Middleware

**Exemplo: `app/api/http/middleware/error_middleware.go`**

```go
package middleware

import (
    "encoding/json"
    "log"
    "net/http"
    
    "github.com/anki/pkg/errors"
)

// ErrorMiddleware captura e trata erros de forma consistente
func ErrorMiddleware() func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            defer func() {
                if err := recover(); err != nil {
                    log.Printf("Panic recovered: %v", err)
                    errors.RespondError(w, http.StatusInternalServerError, "internal server error")
                }
            }()
            
            next.ServeHTTP(w, r)
        })
    }
}

// RespondError responde com erro estruturado
func RespondError(w http.ResponseWriter, statusCode int, message string) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(statusCode)
    
    response := map[string]interface{}{
        "error": map[string]interface{}{
            "message": message,
            "code":    statusCode,
        },
    }
    
    json.NewEncoder(w).Encode(response)
}
```

### 27.2 Logging Middleware

**Exemplo: `app/api/http/middleware/logging_middleware.go`**

```go
package middleware

import (
    "log"
    "net/http"
    "time"
)

// LoggingMiddleware registra todas as requisições
func LoggingMiddleware() func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            start := time.Now()
            
            // Criar response writer wrapper para capturar status code
            rw := &responseWriter{ResponseWriter: w, statusCode: http.StatusOK}
            
            next.ServeHTTP(rw, r)
            
            duration := time.Since(start)
            
            log.Printf(
                "%s %s %d %v %s %s",
                r.Method,
                r.URL.Path,
                rw.statusCode,
                duration,
                r.RemoteAddr,
                r.UserAgent(),
            )
        })
    }
}

type responseWriter struct {
    http.ResponseWriter
    statusCode int
}

func (rw *responseWriter) WriteHeader(code int) {
    rw.statusCode = code
    rw.ResponseWriter.WriteHeader(code)
}
```

### 27.3 Rate Limiting Middleware

**Exemplo: `app/api/http/middleware/rate_limit_middleware.go`**

```go
package middleware

import (
    "context"
    "fmt"
    "net/http"
    "sync"
    "time"
    
    "github.com/anki/infra/cache"
)

// RateLimitMiddleware limita taxa de requisições
func RateLimitMiddleware(cache cache.Cache) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            userID := r.Context().Value("userID")
            if userID == nil {
                next.ServeHTTP(w, r)
                return
            }
            
            key := fmt.Sprintf("rate_limit:%d", userID)
            
            // Verificar limite usando Redis INCR
            // Em produção, usar redis.INCR com TTL
            // Por simplicidade, aqui usamos Get/Set
            data, _ := cache.Get(context.Background(), key)
            count := 0
            if data != nil {
                // Converter bytes para int (simplificado)
                count = 1 // Em produção, parsear bytes
            }
            
            if count >= 100 { // 100 requisições por minuto
                http.Error(w, "Rate limit exceeded", http.StatusTooManyRequests)
                return
            }
            
            // Incrementar contador (usar Redis INCR em produção)
            count++
            cache.Set(context.Background(), key, []byte{byte(count)}, time.Minute)
            
            next.ServeHTTP(w, r)
        })
    }
}
```

### 27.4 Health Check Handler

**Exemplo: `app/api/http/handlers/health_handler.go`**

```go
package handlers

import (
    "database/sql"
    "encoding/json"
    "net/http"
    
    "github.com/anki/infra/cache"
)

type HealthHandler struct {
    db    *sql.DB
    cache cache.Cache
}

func NewHealthHandler(db *sql.DB, cache cache.Cache) *HealthHandler {
    return &HealthHandler{
        db:    db,
        cache: cache,
    }
}

// HealthCheckHandler verifica saúde da aplicação
func (h *HealthHandler) HealthCheckHandler(w http.ResponseWriter, r *http.Request) {
    status := map[string]string{
        "status": "healthy",
    }
    
    // Verificar banco de dados
    if err := h.db.Ping(); err != nil {
        status["database"] = "unhealthy"
        status["status"] = "degraded"
    } else {
        status["database"] = "healthy"
    }
    
    // Verificar cache
    ctx := r.Context()
    if err := h.cache.Ping(ctx); err != nil {
        status["cache"] = "unhealthy"
        status["status"] = "degraded"
    } else {
        status["cache"] = "healthy"
    }
    
    statusCode := http.StatusOK
    if status["status"] == "degraded" {
        statusCode = http.StatusServiceUnavailable
    }
    
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(statusCode)
    json.NewEncoder(w).Encode(status)
}

// ReadinessHandler verifica se aplicação está pronta
func (h *HealthHandler) ReadinessHandler(w http.ResponseWriter, r *http.Request) {
    // Verificar se todos os serviços estão prontos
    if err := h.db.Ping(); err != nil {
        http.Error(w, "Database not ready", http.StatusServiceUnavailable)
        return
    }
    
    w.WriteHeader(http.StatusOK)
}

// LivenessHandler verifica se aplicação está viva
func (h *HealthHandler) LivenessHandler(w http.ResponseWriter, r *http.Request) {
    w.WriteHeader(http.StatusOK)
}
```

## 28. Gerenciamento de Transações

### 28.1 Transaction Manager

**Exemplo: `infra/persistence/transaction_manager.go`**

```go
package persistence

import (
    "context"
    "database/sql"
)

// TransactionManager gerencia transações de banco de dados
type TransactionManager interface {
    Begin(ctx context.Context) (context.Context, error)
    Commit(ctx context.Context) error
    Rollback(ctx context.Context) error
    WithTransaction(ctx context.Context, fn func(context.Context) error) error
}

// PostgresTransactionManager implementa gerenciamento de transações PostgreSQL
type PostgresTransactionManager struct {
    db *sql.DB
}

// NewTransactionManager cria um novo TransactionManager
func NewTransactionManager(db *sql.DB) TransactionManager {
    return &PostgresTransactionManager{db: db}
}

// Begin inicia uma transação
func (tm *PostgresTransactionManager) Begin(ctx context.Context) (context.Context, error) {
    tx, err := tm.db.BeginTx(ctx, nil)
    if err != nil {
        return nil, err
    }
    
    return context.WithValue(ctx, "tx", tx), nil
}

// Commit commita a transação
func (tm *PostgresTransactionManager) Commit(ctx context.Context) error {
    tx := ctx.Value("tx").(*sql.Tx)
    return tx.Commit()
}

// Rollback faz rollback da transação
func (tm *PostgresTransactionManager) Rollback(ctx context.Context) error {
    tx := ctx.Value("tx").(*sql.Tx)
    return tx.Rollback()
}

// WithTransaction executa função dentro de transação
func (tm *PostgresTransactionManager) WithTransaction(
    ctx context.Context,
    fn func(context.Context) error,
) error {
    txCtx, err := tm.Begin(ctx)
    if err != nil {
        return err
    }
    
    defer func() {
        if p := recover(); p != nil {
            tm.Rollback(txCtx)
            panic(p)
        }
    }()
    
    if err := fn(txCtx); err != nil {
        tm.Rollback(txCtx)
        return err
    }
    
    return tm.Commit(txCtx)
}
```

## 29. Background Jobs

### 29.1 Job Queue

**Exemplo: `infra/jobs/job_queue.go`**

```go
package jobs

import (
    "context"
    "time"
)

// Job representa uma tarefa em background
type Job interface {
    Execute(ctx context.Context) error
    RetryCount() int
    MaxRetries() int
}

// JobQueue gerencia fila de jobs
type JobQueue interface {
    Enqueue(ctx context.Context, job Job) error
    Dequeue(ctx context.Context) (Job, error)
    Process(ctx context.Context) error
}

// InMemoryJobQueue implementa fila de jobs em memória
type InMemoryJobQueue struct {
    jobs chan Job
}

// NewJobQueue cria uma nova fila de jobs
func NewJobQueue(size int) JobQueue {
    return &InMemoryJobQueue{
        jobs: make(chan Job, size),
    }
}

// Enqueue adiciona job à fila
func (q *InMemoryJobQueue) Enqueue(ctx context.Context, job Job) error {
    select {
    case q.jobs <- job:
        return nil
    case <-ctx.Done():
        return ctx.Err()
    }
}

// Dequeue remove job da fila
func (q *InMemoryJobQueue) Dequeue(ctx context.Context) (Job, error) {
    select {
    case job := <-q.jobs:
        return job, nil
    case <-ctx.Done():
        return nil, ctx.Err()
    }
}

// Process processa jobs da fila
func (q *InMemoryJobQueue) Process(ctx context.Context) error {
    for {
        select {
        case job := <-q.jobs:
            if err := job.Execute(ctx); err != nil {
                if job.RetryCount() < job.MaxRetries() {
                    // Re-enqueue com retry
                    time.Sleep(time.Second * time.Duration(job.RetryCount()+1))
                    q.Enqueue(ctx, job)
                }
            }
        case <-ctx.Done():
            return ctx.Err()
        }
    }
}
```

### 29.2 Background Jobs Exemplos

**Exemplo: `infra/jobs/media_cleanup_job.go`**

```go
package jobs

import (
    "context"
    
    "github.com/anki/core/domain/repositories"
)

// MediaCleanupJob limpa media não utilizada
type MediaCleanupJob struct {
    mediaRepo repositories.MediaRepository
    retries   int
}

func NewMediaCleanupJob(mediaRepo repositories.MediaRepository) *MediaCleanupJob {
    return &MediaCleanupJob{
        mediaRepo: mediaRepo,
        retries:   0,
    }
}

func (j *MediaCleanupJob) Execute(ctx context.Context) error {
    // Buscar media não utilizada
    unused, err := j.mediaRepo.FindUnused(ctx, 0) // userID seria passado
    if err != nil {
        return err
    }
    
    // Excluir media não utilizada
    for _, media := range unused {
        j.mediaRepo.Delete(ctx, media.ID)
    }
    
    return nil
}

func (j *MediaCleanupJob) RetryCount() int {
    return j.retries
}

func (j *MediaCleanupJob) MaxRetries() int {
    return 3
}
```

## 30. Circuit Breaker

### 30.1 Circuit Breaker Pattern

**Exemplo: `infra/circuitbreaker/circuit_breaker.go`**

```go
package circuitbreaker

import (
    "context"
    "errors"
    "sync"
    "time"
)

var ErrCircuitOpen = errors.New("circuit breaker is open")

// CircuitBreaker implementa padrão circuit breaker
type CircuitBreaker struct {
    maxFailures int
    timeout     time.Duration
    failures    int
    lastFailure time.Time
    state       State
    mu          sync.RWMutex
}

// State representa estado do circuit breaker
type State string

const (
    StateClosed   State = "closed"
    StateOpen     State = "open"
    StateHalfOpen State = "half-open"
)

// NewCircuitBreaker cria um novo CircuitBreaker
func NewCircuitBreaker(maxFailures int, timeout time.Duration) *CircuitBreaker {
    return &CircuitBreaker{
        maxFailures: maxFailures,
        timeout:     timeout,
        state:       StateClosed,
    }
}

// Execute executa função com circuit breaker
func (cb *CircuitBreaker) Execute(ctx context.Context, fn func() error) error {
    cb.mu.RLock()
    state := cb.state
    cb.mu.RUnlock()
    
    switch state {
    case StateOpen:
        if time.Since(cb.lastFailure) > cb.timeout {
            cb.mu.Lock()
            cb.state = StateHalfOpen
            cb.mu.Unlock()
        } else {
            return ErrCircuitOpen
        }
    case StateHalfOpen:
        // Permitir uma tentativa
    case StateClosed:
        // Normal operation
    }
    
    err := fn()
    
    cb.mu.Lock()
    defer cb.mu.Unlock()
    
    if err != nil {
        cb.failures++
        cb.lastFailure = time.Now()
        
        if cb.failures >= cb.maxFailures {
            cb.state = StateOpen
        }
        return err
    }
    
    // Sucesso - reset
    cb.failures = 0
    cb.state = StateClosed
    return nil
}
```

## 34. Background Jobs Detalhado

### 34.1 Job Queue Patterns

**Exemplo: `infra/jobs/job_queue.go`**

```go
package jobs

import (
    "context"
    "encoding/json"
    "time"
    
    "github.com/redis/go-redis/v9"
)

// Job representa uma tarefa em background
type Job struct {
    ID        string
    Type      string
    Payload   map[string]interface{}
    Retries   int
    MaxRetries int
    CreatedAt time.Time
}

// JobQueue gerencia fila de jobs
type JobQueue struct {
    redis  *redis.Client
    queue  string
    worker *WorkerPool
}

func NewJobQueue(redis *redis.Client, queueName string) *JobQueue {
    return &JobQueue{
        redis: redis,
        queue: queueName,
    }
}

// Enqueue adiciona job à fila
func (q *JobQueue) Enqueue(ctx context.Context, jobType string, payload map[string]interface{}) error {
    job := Job{
        ID:        generateJobID(),
        Type:      jobType,
        Payload:   payload,
        Retries:   0,
        MaxRetries: 3,
        CreatedAt: time.Now(),
    }
    
    data, err := json.Marshal(job)
    if err != nil {
        return err
    }
    
    return q.redis.LPush(ctx, q.queue, data).Err()
}

// Dequeue remove e retorna próximo job
func (q *JobQueue) Dequeue(ctx context.Context, timeout time.Duration) (*Job, error) {
    result, err := q.redis.BRPop(ctx, timeout, q.queue).Result()
    if err != nil {
        return nil, err
    }
    
    var job Job
    if err := json.Unmarshal([]byte(result[1]), &job); err != nil {
        return nil, err
    }
    
    return &job, nil
}
```

### 34.2 Worker Pool Pattern

**Exemplo: `infra/jobs/worker_pool.go`**

```go
package jobs

import (
    "context"
    "log"
    "sync"
    "time"
)

// JobHandler processa um tipo específico de job
type JobHandler interface {
    Handle(ctx context.Context, job *Job) error
}

// WorkerPool gerencia pool de workers
type WorkerPool struct {
    workers   int
    queue     *JobQueue
    handlers  map[string]JobHandler
    wg        sync.WaitGroup
    ctx       context.Context
    cancel    context.CancelFunc
}

func NewWorkerPool(workers int, queue *JobQueue) *WorkerPool {
    ctx, cancel := context.WithCancel(context.Background())
    
    return &WorkerPool{
        workers:  workers,
        queue:    queue,
        handlers: make(map[string]JobHandler),
        ctx:      ctx,
        cancel:   cancel,
    }
}

// RegisterHandler registra handler para tipo de job
func (wp *WorkerPool) RegisterHandler(jobType string, handler JobHandler) {
    wp.handlers[jobType] = handler
}

// Start inicia workers
func (wp *WorkerPool) Start() {
    for i := 0; i < wp.workers; i++ {
        wp.wg.Add(1)
        go wp.worker(i)
    }
}

// worker processa jobs da fila
func (wp *WorkerPool) worker(id int) {
    defer wp.wg.Done()
    
    for {
        select {
        case <-wp.ctx.Done():
            return
        default:
            job, err := wp.queue.Dequeue(wp.ctx, 5*time.Second)
            if err != nil {
                continue
            }
            
            handler, ok := wp.handlers[job.Type]
            if !ok {
                log.Printf("Worker %d: No handler for job type %s", id, job.Type)
                continue
            }
            
            if err := handler.Handle(wp.ctx, job); err != nil {
                log.Printf("Worker %d: Job %s failed: %v", id, job.ID, err)
                
                // Retry logic
                if job.Retries < job.MaxRetries {
                    job.Retries++
                    // Re-enqueue com backoff
                    time.Sleep(time.Duration(job.Retries) * time.Second)
                    wp.queue.Enqueue(wp.ctx, job.Type, job.Payload)
                } else {
                    log.Printf("Worker %d: Job %s failed after %d retries", id, job.ID, job.MaxRetries)
                    // Enviar para dead letter queue
                    wp.queue.EnqueueDeadLetter(wp.ctx, job)
                }
            } else {
                log.Printf("Worker %d: Job %s completed successfully", id, job.ID)
            }
        }
    }
}

// Stop para workers
func (wp *WorkerPool) Stop() {
    wp.cancel()
    wp.wg.Wait()
}
```

### 34.3 Retry Strategies

**Exemplo: Retry com Exponential Backoff**:

```go
package jobs

import (
    "math"
    "time"
)

// RetryStrategy define estratégia de retry
type RetryStrategy interface {
    GetDelay(retryCount int) time.Duration
}

// ExponentialBackoff implementa backoff exponencial
type ExponentialBackoff struct {
    InitialDelay time.Duration
    MaxDelay     time.Duration
    Multiplier   float64
}

func (eb *ExponentialBackoff) GetDelay(retryCount int) time.Duration {
    delay := time.Duration(float64(eb.InitialDelay) * math.Pow(eb.Multiplier, float64(retryCount)))
    if delay > eb.MaxDelay {
        return eb.MaxDelay
    }
    return delay
}

// Uso
backoff := &ExponentialBackoff{
    InitialDelay: 1 * time.Second,
    MaxDelay:     60 * time.Second,
    Multiplier:   2.0,
}

delay := backoff.GetDelay(job.Retries)
time.Sleep(delay)
```

### 34.4 Scheduled Jobs (Cron)

**Exemplo: `infra/jobs/scheduler.go`**

```go
package jobs

import (
    "context"
    "time"
    
    "github.com/robfig/cron/v3"
)

// Scheduler gerencia jobs agendados
type Scheduler struct {
    cron    *cron.Cron
    queue   *JobQueue
    ctx     context.Context
}

func NewScheduler(queue *JobQueue) *Scheduler {
    return &Scheduler{
        cron:  cron.New(),
        queue: queue,
        ctx:   context.Background(),
    }
}

// ScheduleJob agenda job recorrente
func (s *Scheduler) ScheduleJob(spec string, jobType string, payload map[string]interface{}) error {
    _, err := s.cron.AddFunc(spec, func() {
        s.queue.Enqueue(s.ctx, jobType, payload)
    })
    return err
}

// Start inicia scheduler
func (s *Scheduler) Start() {
    s.cron.Start()
}

// Stop para scheduler
func (s *Scheduler) Stop() {
    s.cron.Stop()
}

// Uso
scheduler := jobs.NewScheduler(jobQueue)

// Executar a cada hora
scheduler.ScheduleJob("0 * * * *", "cleanup_old_reviews", nil)

// Executar diariamente às 2 AM
scheduler.ScheduleJob("0 2 * * *", "generate_daily_stats", nil)

// Executar a cada 5 minutos
scheduler.ScheduleJob("*/5 * * * *", "sync_shared_decks", nil)

scheduler.Start()
```

### 34.5 Job Monitoring

**Exemplo: Métricas de Jobs**:

```go
var (
    jobsProcessedTotal = promauto.NewCounterVec(
        prometheus.CounterOpts{
            Name: "jobs_processed_total",
            Help: "Total number of jobs processed",
        },
        []string{"job_type", "status"},
    )
    
    jobDuration = promauto.NewHistogramVec(
        prometheus.HistogramOpts{
            Name: "job_duration_seconds",
            Help: "Job processing duration",
        },
        []string{"job_type"},
    )
)

func (wp *WorkerPool) worker(id int) {
    for {
        job, err := wp.queue.Dequeue(wp.ctx, 5*time.Second)
        if err != nil {
            continue
        }
        
        start := time.Now()
        handler := wp.handlers[job.Type]
        
        if err := handler.Handle(wp.ctx, job); err != nil {
            jobsProcessedTotal.WithLabelValues(job.Type, "failed").Inc()
        } else {
            jobsProcessedTotal.WithLabelValues(job.Type, "success").Inc()
        }
        
        jobDuration.WithLabelValues(job.Type).Observe(time.Since(start).Seconds())
    }
}
```

### 34.6 Error Handling em Jobs

**Dead Letter Queue**:

```go
// EnqueueDeadLetter envia job falho para dead letter queue
func (q *JobQueue) EnqueueDeadLetter(ctx context.Context, job *Job) error {
    job.Type = "dead_letter:" + job.Type
    data, _ := json.Marshal(job)
    return q.redis.LPush(ctx, "dead_letter_queue", data).Err()
}

// Monitor dead letter queue para investigação
func (q *JobQueue) GetDeadLetterJobs(ctx context.Context, limit int) ([]*Job, error) {
    results, err := q.redis.LRange(ctx, "dead_letter_queue", 0, int64(limit-1)).Result()
    if err != nil {
        return nil, err
    }
    
    var jobs []*Job
    for _, result := range results {
        var job Job
        if err := json.Unmarshal([]byte(result), &job); err == nil {
            jobs = append(jobs, &job)
        }
    }
    
    return jobs, nil
}
```

## 31. Considerações Finais

### 27.1 Funcionalidades Frontend vs Backend

Algumas funcionalidades são principalmente frontend e não requerem implementação backend detalhada:

- **TTS (Text-to-Speech)**: Processado no cliente usando APIs do navegador/SO
- **Ruby Characters (Furigana)**: Renderização HTML/CSS no frontend
- **RTL (Right-to-Left)**: Direção de texto é CSS no frontend
- **MathJax**: Renderização no navegador via JavaScript

O backend pode armazenar configurações dessas funcionalidades, mas a renderização é feita no frontend.

### 27.2 Extensibilidade

A arquitetura permite adicionar facilmente:

- Novos algoritmos de scheduling (além de SM-2 e FSRS)
- Novos formatos de import/export
- Novos tipos de storage (além de local e S3)
- Novos adapters de cache (além de Redis)
- Novos serviços externos (além de email)

### 27.3 Próximos Passos

Para implementação completa, recomenda-se:

1. **Fase 1 - MVP**: Entidades básicas, repositórios, serviços core (Auth, Deck, Note, Study)
2. **Fase 2 - Funcionalidades**: Sync, Stats, Import/Export, Backups
3. **Fase 3 - Avançado**: Shared Decks, Filtered Decks, Batch Operations
4. **Fase 4 - Otimização**: Cache, Performance, Escalabilidade

### 27.4 Testes

A arquitetura facilita testes:

- **Unit Tests**: Todas as camadas são testáveis via interfaces
- **Integration Tests**: Testes de repositórios com banco de teste
- **E2E Tests**: Testes completos via HTTP handlers

### 27.5 Documentação Adicional Recomendada

- **API Documentation**: Swagger/OpenAPI para endpoints REST
- **Deployment Guide**: Como fazer deploy em produção
- **Development Setup**: Como configurar ambiente de desenvolvimento
- **Contributing Guide**: Como contribuir com o projeto

---

**Versão:** 2.1  
**Última Atualização:** 2024-01-20

Esta documentação arquitetural serve como guia para desenvolvimento, manutenção e evolução do backend do sistema Anki, garantindo que todos os princípios de arquitetura limpa sejam seguidos.

## Guias Detalhados de Referência

Esta documentação fornece uma visão geral completa. Para aprofundamento em tópicos específicos, consulte:

### Princípios Fundamentais

1. **SOLID Principles** - Ver [Seção 5: Princípios SOLID Aplicados](#5-princípios-solid-aplicados)
   - Single Responsibility Principle (SRP)
   - Open/Closed Principle (OCP)
   - Liskov Substitution Principle (LSP)
   - Interface Segregation Principle (ISP)
   - Dependency Inversion Principle (DIP)
   - Exemplos práticos com código Go

2. **Clean Code Principles** - Ver [Seção 13: Clean Code Principles](#13-clean-code-principles-princípios-de-código-limpo)
   - Nomes significativos
   - Funções pequenas e focadas
   - DRY (Don't Repeat Yourself)
   - Comentários explicam POR QUÊ
   - Tratamento de erros adequado

3. **Design Patterns** - Ver [Seção 14: Design Patterns Aplicados](#14-design-patterns-aplicados)
   - Padrões Criacionais (Factory, Singleton)
   - Padrões Estruturais (Adapter, Mapper)
   - Padrões Comportamentais (Strategy, Observer)
   - Padrões Enterprise (Repository, Service Layer, DTO)

### Implementação

4. **Error Handling** - Ver [Seção 4: Error Handling Strategy](#4-error-handling-strategy-estratégia-de-tratamento-de-erros)
   - Hierarquia de erros
   - Domain exceptions
   - Error mapping

5. **Testing** - Ver [Seção 7: Testing Guide](#7-testing-guide)
   - Unit Testing
   - Integration Testing
   - E2E Testing
   - Mocking strategies

6. **Performance** - Ver [Seção 8: Performance Optimization](#8-performance-optimization)
   - N+1 Query Problem
   - Connection Pooling
   - Async operations
   - Caching strategies

7. **Security** - Ver [Seção 9: Security Best Practices](#9-security-best-practices)
   - OWASP Top 10
   - Password hashing
   - SQL injection prevention
   - Security headers

8. **API Design** - Ver [Seção 4: API Design Guide](#4-api-design-guide)
   - REST API best practices
   - API Versioning
   - Rate Limiting
   - Error handling padronizado

## Changelog

### Versão 2.1 (2024-01-20)
- ✅ Adicionada seção "Por Que Arquitetura Hexagonal?" com benefícios detalhados
- ✅ Expandida seção de Technology Stack com detalhes do stack Go
- ✅ Adicionada seção de Code Standards
- ✅ Melhorada seção de Project Organization com convenções (docs/, scripts/)
- ✅ Expandida seção de Layer Responsibilities com exemplos
- ✅ Adicionada seção "SOLID em Prática" ligando arquitetura aos princípios
- ✅ Adicionada seção de referências aos guias detalhados

### Versão 2.0 (2024-01-20)
- ✅ Adicionada seção detalhada sobre Logging Estruturado e Middleware (Seção 26)
- ✅ Expandida seção de Database Migrations com golang-migrate (Seção 21.2)
- ✅ Expandida seção de Performance Optimization com N+1 queries, connection pooling, async, caching (Seção 8)
- ✅ Adicionada nova seção sobre API Design Guide (Seção 4)
- ✅ Expandida seção de Testing Guide com unit, integration, E2E, mocking, fixtures (Seção 7)
- ✅ Expandida seção de Security Best Practices com OWASP Top 10 (Seção 9)
- ✅ Melhorada seção de Environment Variables e Configuração com validação (Seção 21.1)
- ✅ Expandida seção de Monitoring e Observabilidade com métricas, health checks, tracing (Seção 15)
- ✅ Expandida seção de Background Jobs com worker pools, retry strategies, scheduled jobs (Seção 34)

