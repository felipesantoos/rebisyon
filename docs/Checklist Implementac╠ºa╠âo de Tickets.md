# Checklist Genérico para Implementação de Tickets

Este documento fornece um checklist genérico e reutilizável para guiar a implementação de qualquer ticket no sistema Anki, seguindo os princípios de **Arquitetura Hexagonal (Backend)** e **Clean Architecture adaptada para React (Frontend)**.

## 📋 Como Usar Este Checklist

1. **Copie o checklist relevante** (Backend ou Frontend) para o seu ticket
2. **Marque cada item** conforme você completa
3. **Adapte conforme necessário** - nem todos os itens se aplicam a todos os tickets
4. **Use como guia** para garantir que nenhuma camada seja esquecida

---

## 🔵 Checklist Backend (Arquitetura Hexagonal)

### 1. Análise e Planejamento

- [ ] **Analisar requisitos do ticket**
  - [ ] Entender o caso de uso completo
  - [ ] Identificar entidades de domínio envolvidas
  - [ ] Identificar regras de negócio
  - [ ] Identificar validações necessárias

- [ ] **Identificar dependências**
  - [ ] Verificar se novas entidades são necessárias
  - [ ] Verificar se novos repositories são necessários
  - [ ] Verificar se novos services são necessários
  - [ ] Verificar se migrations são necessárias

### 2. Domain Layer (Core - Lógica de Negócio Pura)

- [ ] **Entidades de Domínio** (`core/domain/entities/`)
  - [ ] Criar/atualizar entidades necessárias
  - [ ] Implementar métodos de negócio nas entidades
  - [ ] Adicionar validações de domínio
  - [ ] Garantir que entidades não dependem de frameworks

- [ ] **Value Objects** (`core/domain/valueobjects/`)
  - [ ] Criar value objects se necessário
  - [ ] Implementar validações em value objects
  - [ ] Garantir imutabilidade

- [ ] **Domain Services** (`core/domain/services/`)
  - [ ] Criar domain services para lógica que não pertence a uma entidade
  - [ ] Implementar algoritmos de negócio (ex: scheduler, card generator)
  - [ ] Garantir que domain services não dependem de infraestrutura

- [ ] **Domain Events** (`core/domain/events/`)
  - [ ] Definir domain events se necessário
  - [ ] Implementar estruturas de eventos

### 3. Interfaces (Ports)

- [ ] **Primary Ports** (`core/interfaces/primary/`)
  - [ ] Definir interface do service (ex: `IXxxService`)
  - [ ] Documentar métodos da interface
  - [ ] Definir tipos de retorno e parâmetros
  - [ ] Garantir que interface está no core (não depende de infraestrutura)

- [ ] **Secondary Ports** (`core/interfaces/secondary/`)
  - [ ] Definir interface do repository (ex: `IXxxRepository`)
  - [ ] Documentar métodos do repository
  - [ ] Definir tipos de retorno e parâmetros
  - [ ] Garantir que interface está no core (não depende de infraestrutura)

### 4. Application Services (Use Cases)

- [ ] **Implementar Service** (`core/services/xxx/`)
  - [ ] Implementar interface primary port
  - [ ] Injetar dependências via construtor (repositories, domain services)
  - [ ] Implementar lógica de orquestração
  - [ ] Implementar validações de negócio
  - [ ] Tratar erros de domínio
  - [ ] Garantir que service depende apenas de interfaces (secondary ports)

- [ ] **Filters** (`core/services/filters/`)
  - [ ] Criar filtros se necessário (paginação, ordenação, busca)
  - [ ] Implementar filter pattern reutilizável

### 5. Infrastructure Layer (Adapters)

- [ ] **Database Models** (`infra/database/models/`)
  - [ ] Criar/atualizar models do banco de dados
  - [ ] Definir structs com tags `db:`
  - [ ] Garantir correspondência com schema SQL

- [ ] **Database Mappers** (`infra/database/mappers/`)
  - [ ] Implementar `ToDomain()` (DB Model → Domain Entity)
  - [ ] Implementar `ToModel()` (Domain Entity → DB Model)
  - [ ] Tratar conversões de tipos
  - [ ] Tratar valores nulos/opcionais

- [ ] **Repository Implementations** (`infra/database/repositories/`)
  - [ ] Implementar interface secondary port
  - [ ] Implementar métodos CRUD
  - [ ] Implementar queries SQL
  - [ ] Implementar paginação se necessário
  - [ ] Implementar filtros se necessário
  - [ ] Tratar erros de banco de dados
  - [ ] Garantir transações quando necessário

- [ ] **Migrations** (`migrations/`)
  - [ ] Criar migration UP (criar tabelas/colunas)
  - [ ] Criar migration DOWN (rollback)
  - [ ] Adicionar índices se necessário
  - [ ] Adicionar constraints se necessário
  - [ ] Testar migration UP e DOWN

- [ ] **Cache (Redis)** (`infra/redis/`)
  - [ ] Implementar cache se necessário
  - [ ] Definir estratégia de invalidação
  - [ ] Implementar TTL apropriado

### 6. Application Layer (Primary Adapters - HTTP API)

- [ ] **Request DTOs** (`app/api/dtos/request/`)
  - [ ] Criar structs de request
  - [ ] Adicionar tags JSON
  - [ ] Adicionar validações (tags `validate:`)
  - [ ] Documentar campos

- [ ] **Response DTOs** (`app/api/dtos/response/`)
  - [ ] Criar structs de response
  - [ ] Adicionar tags JSON
  - [ ] Criar DTOs paginados se necessário
  - [ ] Documentar campos

- [ ] **HTTP Mappers** (`app/api/mappers/`)
  - [ ] Implementar `ToDomain()` (Request DTO → Domain Entity)
  - [ ] Implementar `ToResponse()` (Domain Entity → Response DTO)
  - [ ] Implementar `ToResponseList()` se necessário
  - [ ] Tratar conversões de tipos

- [ ] **HTTP Handlers** (`app/api/handlers/` ou `app/api/routes/`)
  - [ ] Criar handlers para cada endpoint
  - [ ] Validar request DTOs
  - [ ] Chamar service via interface (primary port)
  - [ ] Mapear domain para response DTO
  - [ ] Tratar erros HTTP (400, 404, 500, etc.)
  - [ ] Retornar status codes apropriados
  - [ ] Adicionar logging quando necessário

- [ ] **Routes** (`app/api/routes/`)
  - [ ] Registrar rotas no router
  - [ ] Adicionar middlewares necessários (auth, logging, etc.)
  - [ ] Documentar rotas (comentários ou OpenAPI)

- [ ] **Middlewares** (`app/api/middlewares/`)
  - [ ] Criar middlewares específicos se necessário
  - [ ] Implementar validação, autenticação, rate limiting, etc.

### 7. Testes

- [ ] **Testes Unitários - Domain** (`tests/unit/domain/`)
  - [ ] Testar entidades
  - [ ] Testar value objects
  - [ ] Testar domain services
  - [ ] Testar regras de negócio
  - [ ] Cobertura mínima: 80%

- [ ] **Testes Unitários - Services** (`tests/unit/services/`)
  - [ ] Mockar repositories (secondary ports)
  - [ ] Testar casos de sucesso
  - [ ] Testar casos de erro
  - [ ] Testar validações
  - [ ] Testar edge cases
  - [ ] Cobertura mínima: 80%

- [ ] **Testes Unitários - Repositories** (`tests/unit/repositories/`)
  - [ ] Usar banco de dados em memória ou mocks
  - [ ] Testar CRUD operations
  - [ ] Testar queries complexas
  - [ ] Testar paginação
  - [ ] Testar filtros
  - [ ] Cobertura mínima: 70%

- [ ] **Testes Unitários - Handlers** (`tests/unit/handlers/`)
  - [ ] Mockar services (primary ports)
  - [ ] Testar validação de requests
  - [ ] Testar mapeamento de responses
  - [ ] Testar status codes
  - [ ] Testar tratamento de erros

- [ ] **Testes de Integração** (`tests/integration/`)
  - [ ] Testar fluxo completo (Handler → Service → Repository → DB)
  - [ ] Testar com banco de dados real (testcontainers ou similar)
  - [ ] Testar transações
  - [ ] Testar rollbacks

- [ ] **Testes E2E** (`tests/e2e/`)
  - [ ] Testar endpoints completos via HTTP
  - [ ] Testar autenticação/autorização
  - [ ] Testar cenários de usuário completos

### 8. Documentação

- [ ] **Documentação de Código**
  - [ ] Adicionar comentários godoc em interfaces públicas
  - [ ] Documentar parâmetros e retornos
  - [ ] Adicionar exemplos de uso quando relevante

- [ ] **Documentação de API**
  - [ ] Atualizar documentação de endpoints (OpenAPI/Swagger)
  - [ ] Documentar request/response examples
  - [ ] Documentar códigos de erro

- [ ] **Documentação de Migrations**
  - [ ] Documentar mudanças no schema
  - [ ] Documentar breaking changes

### 9. Validação Final

- [ ] **Code Quality**
  - [ ] Executar `gofmt`
  - [ ] Executar `golint` ou `golangci-lint`
  - [ ] Executar `go vet`
  - [ ] Corrigir todos os warnings

- [ ] **Testes**
  - [ ] Todos os testes passando
  - [ ] Cobertura de código adequada
  - [ ] Executar testes de integração

- [ ] **Build**
  - [ ] Build bem-sucedido
  - [ ] Sem erros de compilação
  - [ ] Dependências atualizadas

- [ ] **Review**
  - [ ] Código revisado por pares
  - [ ] Seguindo padrões do projeto
  - [ ] Sem código comentado ou dead code

---

## 🟢 Checklist Frontend (Clean Architecture - React)

### 1. Análise e Planejamento

- [ ] **Analisar requisitos do ticket**
  - [ ] Entender o caso de uso completo
  - [ ] Identificar entidades TypeScript envolvidas
  - [ ] Identificar componentes necessários
  - [ ] Identificar rotas necessárias

- [ ] **Identificar dependências**
  - [ ] Verificar se novas entidades são necessárias
  - [ ] Verificar se novos serviços de API são necessários
  - [ ] Verificar se novos hooks são necessários
  - [ ] Verificar se novos componentes são necessários

### 2. Domain Layer (Entidades e Lógica de Negócio)

- [ ] **TypeScript Entities** (`src/entities/`)
  - [ ] Criar/atualizar interfaces TypeScript
  - [ ] Definir tipos e interfaces
  - [ ] Adicionar validações TypeScript (zod, yup, etc.)
  - [ ] Garantir que entidades não dependem de frameworks

- [ ] **Value Objects** (`src/entities/` ou `src/core/domain/`)
  - [ ] Criar value objects se necessário
  - [ ] Implementar validações
  - [ ] Garantir imutabilidade

- [ ] **Domain Services** (`src/core/services/`)
  - [ ] Criar domain services para lógica de negócio
  - [ ] Implementar regras de negócio puras
  - [ ] Garantir que não dependem de React ou APIs

### 3. Infrastructure Layer (Adaptadores Externos)

- [ ] **HTTP Client** (`src/infra/http/`)
  - [ ] Configurar interceptors se necessário
  - [ ] Adicionar headers de autenticação
  - [ ] Tratar erros HTTP

- [ ] **API Services** (`src/services/api/` ou `src/features/xxx/services/`)
  - [ ] Criar serviços de API para endpoints
  - [ ] Implementar métodos CRUD
  - [ ] Tipar requests e responses
  - [ ] Tratar erros de API
  - [ ] Implementar retry logic se necessário

- [ ] **WebSocket Client** (`src/infra/websocket/`)
  - [ ] Implementar conexão WebSocket se necessário
  - [ ] Tratar reconexão
  - [ ] Tratar eventos

### 4. Application Layer (Lógica de Aplicação)

- [ ] **Redux Slices** (`src/features/xxx/slice.ts`)
  - [ ] Criar/atualizar slice
  - [ ] Definir estado inicial
  - [ ] Criar actions síncronas
  - [ ] Criar async thunks (createAsyncThunk)
  - [ ] Implementar reducers
  - [ ] Implementar extraReducers para async thunks
  - [ ] Exportar actions e reducer

- [ ] **RTK Query** (`src/features/xxx/services/xxx.api.ts`)
  - [ ] Criar/atualizar API slice
  - [ ] Definir endpoints (query/mutation)
  - [ ] Configurar tags para cache invalidation
  - [ ] Exportar hooks (useXxxQuery, useXxxMutation)

- [ ] **Application Hooks** (`src/features/xxx/hooks/`)
  - [ ] Criar hooks customizados
  - [ ] Encapsular lógica de aplicação
  - [ ] Coordenar múltiplos serviços
  - [ ] Gerenciar estado local se necessário
  - [ ] Retornar dados, loading, error states

### 5. Presentation Layer (Componentes React)

- [ ] **UI Components** (`src/shared/components/ui/`)
  - [ ] Criar componentes reutilizáveis se necessário
  - [ ] Implementar props TypeScript
  - [ ] Adicionar variantes (size, variant, etc.)
  - [ ] Adicionar acessibilidade (ARIA)
  - [ ] Adicionar estilos (Tailwind CSS)

- [ ] **Feature Components** (`src/features/xxx/components/`)
  - [ ] Criar componentes específicos da feature
  - [ ] Usar hooks customizados
  - [ ] Gerenciar estado local (useState)
  - [ ] Implementar handlers de eventos
  - [ ] Tratar estados de loading/error
  - [ ] Adicionar feedback visual

- [ ] **Pages** (`src/features/xxx/pages/` ou `src/app/pages/`)
  - [ ] Criar páginas (rotas)
  - [ ] Compor componentes
  - [ ] Gerenciar layout
  - [ ] Tratar estados globais (loading, error)

### 6. Routing

- [ ] **Routes** (`src/app/router/`)
  - [ ] Adicionar rotas no router
  - [ ] Configurar rotas protegidas se necessário
  - [ ] Adicionar lazy loading se necessário
  - [ ] Configurar breadcrumbs se necessário

### 7. Testes

- [ ] **Testes Unitários - Components** (`tests/unit/components/`)
  - [ ] Testar renderização
  - [ ] Testar interações do usuário
  - [ ] Testar props
  - [ ] Testar estados (loading, error, success)
  - [ ] Usar React Testing Library
  - [ ] Cobertura mínima: 70%

- [ ] **Testes Unitários - Hooks** (`tests/unit/hooks/`)
  - [ ] Mockar serviços de API
  - [ ] Testar lógica de hooks
  - [ ] Testar estados retornados
  - [ ] Usar @testing-library/react-hooks

- [ ] **Testes Unitários - Services** (`tests/unit/services/`)
  - [ ] Mockar HTTP client
  - [ ] Testar chamadas de API
  - [ ] Testar tratamento de erros
  - [ ] Testar transformações de dados

- [ ] **Testes Unitários - Redux** (`tests/unit/redux/`)
  - [ ] Testar actions
  - [ ] Testar reducers
  - [ ] Testar async thunks
  - [ ] Testar seletores

- [ ] **Testes de Integração** (`tests/integration/`)
  - [ ] Testar fluxo completo (Component → Hook → Service → API)
  - [ ] Mockar API responses
  - [ ] Testar interações do usuário completas

- [ ] **Testes E2E** (`tests/e2e/`)
  - [ ] Testar fluxos completos de usuário
  - [ ] Testar navegação
  - [ ] Testar autenticação
  - [ ] Usar Cypress ou Playwright

### 8. Estilização

- [ ] **Tailwind CSS**
  - [ ] Aplicar classes Tailwind
  - [ ] Seguir design system
  - [ ] Garantir responsividade
  - [ ] Garantir acessibilidade (cores, contrastes)

- [ ] **Componentes UI**
  - [ ] Usar componentes do design system
  - [ ] Manter consistência visual
  - [ ] Adicionar estados visuais (hover, focus, disabled)

### 9. Validação Final

- [ ] **Code Quality**
  - [ ] Executar ESLint
  - [ ] Executar Prettier
  - [ ] Corrigir todos os warnings
  - [ ] Verificar tipos TypeScript (sem `any` desnecessários)

- [ ] **Testes**
  - [ ] Todos os testes passando
  - [ ] Cobertura de código adequada
  - [ ] Executar testes de integração

- [ ] **Build**
  - [ ] Build bem-sucedido
  - [ ] Sem erros de compilação TypeScript
  - [ ] Bundle size verificado

- [ ] **Acessibilidade**
  - [ ] Testar com screen reader
  - [ ] Verificar contraste de cores
  - [ ] Verificar navegação por teclado
  - [ ] Adicionar ARIA labels quando necessário

- [ ] **Performance**
  - [ ] Verificar re-renders desnecessários
  - [ ] Implementar memoização se necessário
  - [ ] Verificar lazy loading de componentes pesados

- [ ] **Review**
  - [ ] Código revisado por pares
  - [ ] Seguindo padrões do projeto
  - [ ] Sem código comentado ou dead code

---

## 🔄 Checklist Genérico (Aplicável a Ambos)

### 1. Antes de Começar

- [ ] **Entender o ticket completamente**
  - [ ] Ler descrição completa
  - [ ] Verificar dependências de outros tickets
  - [ ] Clarificar dúvidas com o time

- [ ] **Planejar a implementação**
  - [ ] Identificar todas as camadas afetadas
  - [ ] Identificar arquivos que precisam ser criados/modificados
  - [ ] Estimar tempo necessário

### 2. Durante a Implementação

- [ ] **Seguir padrões do projeto**
  - [ ] Seguir convenções de nomenclatura
  - [ ] Seguir estrutura de diretórios
  - [ ] Seguir padrões de código

- [ ] **Manter arquitetura limpa**
  - [ ] Respeitar dependências entre camadas
  - [ ] Não criar dependências circulares
  - [ ] Manter separação de responsabilidades

- [ ] **Escrever código testável**
  - [ ] Evitar acoplamento forte
  - [ ] Usar injeção de dependências
  - [ ] Facilitar criação de mocks

### 3. Antes de Finalizar

- [ ] **Revisar código próprio**
  - [ ] Ler código completo
  - [ ] Verificar se faz sentido
  - [ ] Verificar se está completo

- [ ] **Testar manualmente**
  - [ ] Testar casos de sucesso
  - [ ] Testar casos de erro
  - [ ] Testar edge cases

- [ ] **Documentar mudanças**
  - [ ] Atualizar documentação se necessário
  - [ ] Adicionar comentários quando relevante
  - [ ] Documentar decisões arquiteturais importantes

### 4. Antes de Fazer Merge

- [ ] **Todos os checklists completos**
  - [ ] Backend checklist completo (se aplicável)
  - [ ] Frontend checklist completo (se aplicável)
  - [ ] Checklist genérico completo

- [ ] **Code review**
  - [ ] Solicitar review
  - [ ] Responder comentários
  - [ ] Fazer ajustes necessários

- [ ] **CI/CD**
  - [ ] Todos os testes passando no CI
  - [ ] Build bem-sucedido
  - [ ] Sem erros de lint

---

## 📝 Notas Importantes

### Princípios a Seguir

1. **Dependency Inversion**: Camadas externas dependem de abstrações (interfaces) definidas nas camadas internas
2. **Separation of Concerns**: Cada camada tem responsabilidade única
3. **Single Responsibility**: Cada classe/função tem uma única responsabilidade
4. **Testability**: Código deve ser fácil de testar
5. **Maintainability**: Código deve ser fácil de manter e evoluir

### Quando Adaptar o Checklist

- **Tickets pequenos**: Nem todos os itens se aplicam
- **Tickets de bugfix**: Focar em testes e correção
- **Tickets de refatoração**: Focar em manter funcionalidade existente
- **Tickets de infraestrutura**: Adaptar para camadas de infraestrutura

### Dicas

- ✅ **Marque itens conforme completa** - ajuda a não esquecer nada
- ✅ **Use como guia, não como regra rígida** - adapte conforme necessário
- ✅ **Revise antes de finalizar** - garante qualidade
- ✅ **Peça ajuda quando necessário** - não hesite em perguntar

---

## 🔗 Referências

- [Arquitetura Backend - Sistema Anki](./Arquitetura%20Backend%20-%20Sistema%20Anki.md)
- [Arquitetura Frontend - Sistema Anki](./Arquitetura%20Frontend%20-%20Sistema%20Anki.md)
- [Regras de Negócio - Sistema Anki](./Regras%20de%20Negócio%20-%20Sistema%20Anki.md)
- [Especificação API REST - Sistema Anki](./Especificação%20API%20REST%20-%20Sistema%20Anki.md)

