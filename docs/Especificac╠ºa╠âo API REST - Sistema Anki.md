# Especificação API REST - Sistema Anki Completo

Este documento contém a especificação completa da API REST para o sistema Anki.

## 1. Informações Gerais

### 1.1 Base URL

```
Produção: https://api.anki.example.com/v1
Desenvolvimento: http://localhost:8080/api/v1
```

### 1.2 Versionamento

A API usa versionamento por URL. A versão atual é `v1`.

### 1.3 Formato de Dados

- **Content-Type**: `application/json`
- **Accept**: `application/json`
- **Encoding**: UTF-8
- **Datas**: ISO 8601 (ex: `2024-01-15T10:30:00Z`)

### 1.4 Autenticação

A API usa JWT (JSON Web Tokens) para autenticação.

**Header de Autenticação:**
```
Authorization: Bearer <token>
```

**Refresh Token:**
Enviado via cookie `refresh_token` (HttpOnly, Secure).

### 1.5 Paginação

Endpoints que retornam listas suportam paginação:

**Query Parameters:**
- `page` (integer, default: 1): Número da página
- `limit` (integer, default: 20, max: 100): Itens por página
- `sort` (string): Campo para ordenação
- `order` (string, enum: `asc`, `desc`, default: `asc`): Direção da ordenação

**Response Headers:**
- `X-Total-Count`: Total de itens
- `X-Page`: Página atual
- `X-Per-Page`: Itens por página
- `X-Total-Pages`: Total de páginas

**Response Body:**
```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

### 1.6 Códigos de Status HTTP

- `200 OK`: Requisição bem-sucedida
- `201 Created`: Recurso criado com sucesso
- `204 No Content`: Requisição bem-sucedida sem conteúdo
- `400 Bad Request`: Requisição inválida
- `401 Unauthorized`: Não autenticado
- `403 Forbidden`: Não autorizado
- `404 Not Found`: Recurso não encontrado
- `409 Conflict`: Conflito (ex: duplicata)
- `422 Unprocessable Entity`: Validação falhou
- `429 Too Many Requests`: Rate limit excedido
- `500 Internal Server Error`: Erro interno do servidor
- `503 Service Unavailable`: Serviço temporariamente indisponível

### 1.7 Formato de Erro

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Mensagem de erro legível",
    "details": {
      "field": "Campo específico com erro",
      "reason": "Detalhes do erro"
    },
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### 1.8 Rate Limiting

**Headers de Rate Limit:**
- `X-RateLimit-Limit`: Limite de requisições por janela
- `X-RateLimit-Remaining`: Requisições restantes
- `X-RateLimit-Reset`: Timestamp de reset

**Limites:**
- Autenticação: 5 requisições/minuto
- API geral: 100 requisições/minuto por usuário
- Upload de media: 10 requisições/minuto

## 2. Autenticação

### 2.1 Registro de Usuário

**POST** `/auth/register`

Registra um novo usuário no sistema.

**Request Body:**
```json
{
  "email": "usuario@example.com",
  "password": "senhaSegura123",
  "password_confirm": "senhaSegura123"
}
```

**Response:** `201 Created`
```json
{
  "data": {
    "user": {
      "id": 1,
      "email": "usuario@example.com",
      "email_verified": false,
      "created_at": "2024-01-15T10:30:00Z"
    },
    "message": "Conta criada com sucesso. Verifique seu email para ativar."
  }
}
```

**Erros:**
- `400`: Email inválido ou senha não atende critérios
- `409`: Email já cadastrado

### 2.2 Login

**POST** `/auth/login`

Autentica um usuário e retorna tokens.

**Request Body:**
```json
{
  "email": "usuario@example.com",
  "password": "senhaSegura123"
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "refresh_token_here",
    "expires_in": 3600,
    "token_type": "Bearer",
    "user": {
      "id": 1,
      "email": "usuario@example.com",
      "email_verified": true
    }
  }
}
```

**Erros:**
- `401`: Credenciais inválidas
- `403`: Conta não verificada

### 2.3 Refresh Token

**POST** `/auth/refresh`

Renova o access token usando o refresh token.

**Request Body:**
```json
{
  "refresh_token": "refresh_token_here"
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 3600,
    "token_type": "Bearer"
  }
}
```

### 2.4 Logout

**POST** `/auth/logout`

Invalida tanto o access token quanto o refresh token do usuário. O access token é adicionado a uma blacklist no Redis e o refresh token é removido do Redis.

**Comportamento de Invalidação:**

1. **Access Token:**
   - O access token é adicionado a uma blacklist no Redis com TTL igual ao tempo restante de expiração do token
   - Tokens já expirados não são adicionados à blacklist (não há necessidade)
   - Tokens inválidos também são adicionados à blacklist para prevenir vazamento de informação sobre a validade do token
   - O middleware de autenticação verifica a blacklist antes de validar tokens, garantindo que tokens invalidados não possam ser usados

2. **Refresh Token:**
   - O refresh token é removido do Redis, invalidando-o imediatamente
   - Após a invalidação, o refresh token não pode mais ser usado para obter novos tokens

3. **Casos Especiais:**
   - É possível fazer logout apenas com o access token (sem fornecer refresh token)
   - É possível fazer logout apenas com o refresh token (sem fornecer access token)
   - Pelo menos um dos tokens deve ser fornecido (access token no header Authorization ou refresh token no body)
   - A operação é idempotente: fazer logout múltiplas vezes com o mesmo token não causa erro

**Headers:**
- `Authorization: Bearer <access_token>` (opcional, mas recomendado)

**Request Body (opcional):**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Notas:**
- Pelo menos um token deve ser fornecido (access token no header ou refresh token no body)
- Após o logout, tokens invalidados retornarão erro 401 (Unauthorized) se tentarem ser usados
- O middleware de autenticação verifica automaticamente a blacklist antes de validar qualquer token

**Response:** `200 OK`
```json
{
  "message": "Logged out successfully"
}
```

**Erros:**
- `400 Bad Request`: Nenhum token fornecido (nem access token no header nem refresh token no body)
- `401 Unauthorized`: Token inválido (apenas se o refresh token fornecido for de tipo incorreto)
- `500 Internal Server Error`: Erro ao invalidar tokens no Redis

### 2.5 Verificar Email

**POST** `/auth/verify-email`

Envia email de verificação.

**Request Body:**
```json
{
  "email": "usuario@example.com"
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "message": "Email de verificação enviado"
  }
}
```

### 2.6 Confirmar Email

**GET** `/auth/verify-email/:token`

Confirma email usando token enviado por email.

**Response:** `200 OK`
```json
{
  "data": {
    "message": "Email verificado com sucesso"
  }
}
```

### 2.7 Recuperar Senha

**POST** `/auth/forgot-password`

Envia email com link para redefinir senha.

**Request Body:**
```json
{
  "email": "usuario@example.com"
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "message": "Email de recuperação enviado"
  }
}
```

### 2.8 Redefinir Senha

**POST** `/auth/reset-password`

Redefine senha usando token de recuperação.

**Request Body:**
```json
{
  "token": "reset_token_here",
  "password": "novaSenha123",
  "password_confirm": "novaSenha123"
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "message": "Senha redefinida com sucesso"
  }
}
```

### 2.9 Alterar Senha

**PUT** `/auth/change-password`

Altera senha do usuário autenticado.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "current_password": "senhaAtual123",
  "new_password": "novaSenha123",
  "new_password_confirm": "novaSenha123"
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "message": "Senha alterada com sucesso"
  }
}
```

## 3. Perfil do Usuário

### 3.1 Obter Perfil

**GET** `/users/me`

Retorna informações do usuário autenticado.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "email": "usuario@example.com",
    "email_verified": true,
    "created_at": "2024-01-15T10:30:00Z",
    "last_login_at": "2024-01-20T15:45:00Z"
  }
}
```

### 3.2 Atualizar Perfil

**PUT** `/users/me`

Atualiza informações do perfil.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "email": "novoemail@example.com"
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "email": "novoemail@example.com",
    "email_verified": false,
    "updated_at": "2024-01-20T16:00:00Z"
  }
}
```

## 4. Decks

### 4.1 Listar Decks

**GET** `/decks`

Lista todos os decks do usuário.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `include_stats` (boolean, default: false): Incluir estatísticas
- `include_children` (boolean, default: true): Incluir subdecks

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "name": "Default",
      "parent_id": null,
      "options": {
        "new_cards_per_day": 20,
        "max_reviews_per_day": 200,
        "scheduler": "sm2"
      },
      "stats": {
        "new_count": 10,
        "learning_count": 5,
        "review_count": 50
      },
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-20T15:45:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 1,
    "total_pages": 1
  }
}
```

### 4.2 Criar Deck

**POST** `/decks`

Cria um novo deck.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Novo Deck",
  "parent_id": null,
  "options": {
    "new_cards_per_day": 20,
    "max_reviews_per_day": 200,
    "scheduler": "sm2"
  }
}
```

**Response:** `201 Created`
```json
{
  "data": {
    "id": 2,
    "name": "Novo Deck",
    "parent_id": null,
    "options": {
      "new_cards_per_day": 20,
      "max_reviews_per_day": 200,
      "scheduler": "sm2"
    },
    "created_at": "2024-01-20T16:00:00Z",
    "updated_at": "2024-01-20T16:00:00Z"
  }
}
```

### 4.3 Obter Deck

**GET** `/decks/:id`

Retorna informações de um deck específico.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `include_stats` (boolean, default: true): Incluir estatísticas
- `include_cards` (boolean, default: false): Incluir lista de cards

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "name": "Default",
    "parent_id": null,
    "options": {
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
      "review_sort_order": "due",
      "leech_threshold": 8,
      "leech_action": "suspend",
      "audio_auto_play": true,
      "audio_replay_buttons": true,
      "interrupt_audio_on_answer": true,
      "max_answer_seconds": 60,
      "show_timer": false,
      "stop_timer_on_answer": false,
      "auto_advance_question_seconds": 0,
      "auto_advance_answer_seconds": 0,
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
    },
    "stats": {
      "new_count": 10,
      "learning_count": 5,
      "review_count": 50,
      "suspended_count": 2,
      "notes_count": 65
    },
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-20T15:45:00Z"
  }
}
```

### 4.4 Atualizar Deck

**PUT** `/decks/:id`

Atualiza um deck existente.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Deck Atualizado",
  "options": {
    "new_cards_per_day": 30
  }
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "name": "Deck Atualizado",
    "updated_at": "2024-01-20T16:05:00Z"
  }
}
```

### 4.5 Excluir Deck

**DELETE** `/decks/:id`

Exclui um deck.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `move_cards_to` (integer, optional): ID do deck para mover cards antes de excluir

**Response:** `204 No Content`

**Erros:**
- `409`: Deck contém cards e `move_cards_to` não foi fornecido

### 4.6 Obter Opções do Deck

**GET** `/decks/:id/options`

Retorna opções do deck.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "preset_id": 1,
    "new_cards_per_day": 20,
    "max_reviews_per_day": 200,
    "scheduler": "sm2",
    "fsrs_enabled": false,
    "desired_retention": 0.9
  }
}
```

### 4.7 Atualizar Opções do Deck

**PUT** `/decks/:id/options`

Atualiza opções do deck.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "new_cards_per_day": 30,
  "max_reviews_per_day": 300,
  "scheduler": "fsrs",
  "fsrs_enabled": true,
  "desired_retention": 0.85
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "message": "Opções atualizadas com sucesso"
  }
}
```

### 4.8 Reorganizar Decks

**PUT** `/decks/reorder`

Reorganiza a ordem/hierarquia dos decks.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "decks": [
    {
      "id": 1,
      "parent_id": null,
      "order": 0
    },
    {
      "id": 2,
      "parent_id": 1,
      "order": 0
    }
  ]
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "message": "Decks reorganizados com sucesso"
  }
}
```

## 5. Presets de Opções de Deck

### 5.1 Listar Presets

**GET** `/deck-options-presets`

Lista todos os presets de opções.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "name": "Default",
      "options": {
        "new_cards_per_day": 20,
        "max_reviews_per_day": 200
      },
      "created_at": "2024-01-15T10:30:00Z"
    }
  ]
}
```

### 5.2 Criar Preset

**POST** `/deck-options-presets`

Cria um novo preset.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Intensivo",
  "options": {
    "new_cards_per_day": 50,
    "max_reviews_per_day": 500
  }
}
```

**Response:** `201 Created`
```json
{
  "data": {
    "id": 2,
    "name": "Intensivo",
    "options": {
      "new_cards_per_day": 50,
      "max_reviews_per_day": 500
    },
    "created_at": "2024-01-20T16:00:00Z"
  }
}
```

### 5.3 Atualizar Preset

**PUT** `/deck-options-presets/:id`

Atualiza um preset existente.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Intensivo Atualizado",
  "options": {
    "new_cards_per_day": 60
  }
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "id": 2,
    "name": "Intensivo Atualizado",
    "updated_at": "2024-01-20T16:05:00Z"
  }
}
```

### 5.4 Excluir Preset

**DELETE** `/deck-options-presets/:id`

Exclui um preset.

**Headers:** `Authorization: Bearer <token>`

**Response:** `204 No Content`

## 6. Notes

### 6.1 Listar Notes

**GET** `/notes`

Lista notes do usuário.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `deck_id` (integer, optional): Filtrar por deck
- `note_type_id` (integer, optional): Filtrar por note type
- `tags` (string, optional): Filtrar por tags (separadas por vírgula)
- `marked` (boolean, optional): Filtrar por marked
- `search` (string, optional): Busca textual

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "guid": "550e8400-e29b-41d4-a716-446655440000",
      "note_type_id": 1,
      "fields": {
        "Front": "Hello",
        "Back": "Olá"
      },
      "tags": ["vocabulary", "english"],
      "marked": false,
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-20T15:45:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

### 6.2 Criar Note

**POST** `/notes`

Cria uma nova note.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "note_type_id": 1,
  "deck_id": 1,
  "fields": {
    "Front": "Hello",
    "Back": "Olá"
  },
  "tags": ["vocabulary", "english"]
}
```

**Response:** `201 Created`
```json
{
  "data": {
    "id": 1,
    "guid": "550e8400-e29b-41d4-a716-446655440000",
    "note_type_id": 1,
    "fields": {
      "Front": "Hello",
      "Back": "Olá"
    },
    "tags": ["vocabulary", "english"],
    "marked": false,
    "cards": [
      {
        "id": 1,
        "card_type_id": 0,
        "deck_id": 1,
        "state": "new"
      }
    ],
    "created_at": "2024-01-20T16:00:00Z",
    "updated_at": "2024-01-20T16:00:00Z"
  }
}
```

### 6.3 Obter Note

**GET** `/notes/:id`

Retorna uma note específica.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `include_cards` (boolean, default: true): Incluir cards relacionados

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "guid": "550e8400-e29b-41d4-a716-446655440000",
    "note_type_id": 1,
    "fields": {
      "Front": "Hello",
      "Back": "Olá"
    },
    "tags": ["vocabulary", "english"],
    "marked": false,
    "cards": [
      {
        "id": 1,
        "card_type_id": 0,
        "deck_id": 1,
        "state": "new",
        "due": 0,
        "interval": 0,
        "ease": 2500
      }
    ],
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-20T15:45:00Z"
  }
}
```

### 6.4 Atualizar Note

**PUT** `/notes/:id`

Atualiza uma note existente.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "fields": {
    "Front": "Hello World",
    "Back": "Olá Mundo"
  },
  "tags": ["vocabulary", "english", "updated"],
  "marked": true
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "updated_at": "2024-01-20T16:05:00Z"
  }
}
```

### 6.5 Excluir Note

**DELETE** `/notes/:id`

Exclui uma note e todos os cards relacionados.

**Headers:** `Authorization: Bearer <token>`

**Response:** `204 No Content`

### 6.6 Buscar Notes

**POST** `/notes/search`

Busca avançada de notes usando sintaxe Anki.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "query": "deck:Default tag:vocabulary front:hello",
  "limit": 20,
  "offset": 0
}
```

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "guid": "550e8400-e29b-41d4-a716-446655440000",
      "fields": {
        "Front": "Hello",
        "Back": "Olá"
      },
      "tags": ["vocabulary", "english"]
    }
  ],
  "total": 10
}
```

### 6.7 Criar Cópia de Note

**POST** `/notes/:id/copy`

Cria uma cópia de uma note existente.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "deck_id": 1,
  "copy_tags": true,
  "copy_media": true
}
```

**Response:** `201 Created`
```json
{
  "data": {
    "id": 2,
    "guid": "550e8400-e29b-41d4-a716-446655440001",
    "note_id": 1,
    "created_at": "2024-01-20T16:00:00Z"
  }
}
```

### 6.8 Encontrar Duplicatas

**POST** `/notes/find-duplicates`

Encontra notes duplicadas baseado no primeiro campo.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "note_type_id": 1,
  "field_name": "Front"
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "duplicates": [
      {
        "first_field": "Hello",
        "notes": [
          {
            "id": 1,
            "guid": "550e8400-e29b-41d4-a716-446655440000",
            "deck_id": 1,
            "created_at": "2024-01-15T10:30:00Z"
          },
          {
            "id": 2,
            "guid": "550e8400-e29b-41d4-a716-446655440001",
            "deck_id": 1,
            "created_at": "2024-01-16T10:30:00Z"
          }
        ]
      }
    ],
    "total_duplicates": 1
  }
}
```

### 6.9 Exportar Notes Selecionadas

**POST** `/notes/export`

Exporta notes selecionadas como arquivo.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "note_ids": [1, 2, 3],
  "format": "apkg",
  "include_media": true,
  "include_scheduling": false
}
```

**Response:** `200 OK`
- Content-Type: `application/zip` (apkg) ou `text/plain` (text)
- Content-Disposition: attachment; filename="notes_export.apkg"

### 6.10 Recuperar Exclusões Recentes

**GET** `/notes/deletions`

Lista exclusões recentes que podem ser recuperadas.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `limit` (integer, default: 20): Limite de exclusões a retornar
- `days` (integer, default: 7): Período em dias

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "object_type": "note",
      "object_id": 1,
      "object_data": {
        "guid": "550e8400-e29b-41d4-a716-446655440000",
        "note_type_id": 1,
        "fields": {
          "Front": "Hello",
          "Back": "Olá"
        },
        "tags": ["vocabulary"]
      },
      "deleted_at": "2024-01-20T15:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 5,
    "total_pages": 1
  }
}
```

### 6.11 Restaurar Exclusão

**POST** `/notes/deletions/:id/restore`

Restaura uma note excluída recentemente.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "deck_id": 1
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "guid": "550e8400-e29b-41d4-a716-446655440000",
    "restored_at": "2024-01-20T16:00:00Z",
    "message": "Note restaurada com sucesso"
  }
}
```

## 7. Cards

### 7.1 Listar Cards

**GET** `/cards`

Lista cards do usuário.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `deck_id` (integer, optional): Filtrar por deck
- `state` (string, enum: `new`, `learn`, `review`, `relearn`, optional): Filtrar por estado
- `flag` (integer, 0-7, optional): Filtrar por flag
- `suspended` (boolean, optional): Filtrar por suspended
- `buried` (boolean, optional): Filtrar por buried

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "note_id": 1,
      "card_type_id": 0,
      "deck_id": 1,
      "home_deck_id": null,
      "due": 1705766400000,
      "interval": 1,
      "ease": 2500,
      "lapses": 0,
      "reps": 0,
      "state": "review",
      "position": 0,
      "flag": 0,
      "suspended": false,
      "buried": false,
      "stability": null,
      "difficulty": null,
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-20T15:45:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

### 7.2 Obter Card

**GET** `/cards/:id`

Retorna um card específico.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `include_note` (boolean, default: true): Incluir note relacionada
- `include_reviews` (boolean, default: false): Incluir histórico de revisões

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "note_id": 1,
    "card_type_id": 0,
    "deck_id": 1,
    "due": 1705766400000,
    "interval": 1,
    "ease": 2500,
    "lapses": 0,
    "reps": 0,
    "state": "review",
    "flag": 0,
    "suspended": false,
    "buried": false,
    "note": {
      "id": 1,
      "fields": {
        "Front": "Hello",
        "Back": "Olá"
      },
      "tags": ["vocabulary"]
    },
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-20T15:45:00Z"
  }
}
```

### 7.3 Informações Detalhadas do Card

**GET** `/cards/:id/info`

Retorna informações detalhadas do card (Card Info Dialog).

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "card_id": 1,
    "note_id": 1,
    "deck_name": "Default",
    "note_type_name": "Basic",
    "fields": {
      "Front": "Hello",
      "Back": "Olá"
    },
    "tags": ["vocabulary"],
    "created_at": "2024-01-15T10:30:00Z",
    "first_review": "2024-01-16T10:00:00Z",
    "last_review": "2024-01-20T15:45:00Z",
    "total_reviews": 5,
    "ease_history": [2500, 2600, 2500, 2400, 2500],
    "interval_history": [1, 2, 4, 1, 2],
    "review_history": [
      {
        "rating": 3,
        "interval": 1,
        "ease": 2500,
        "time_ms": 5000,
        "type": "review",
        "created_at": "2024-01-20T15:45:00Z"
      }
    ]
  }
}
```

### 7.4 Atualizar Flag

**POST** `/cards/:id/flag`

Atualiza a flag de um card.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "flag": 1
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "flag": 1,
    "updated_at": "2024-01-20T16:05:00Z"
  }
}
```

### 7.5 Enterrar Card

**POST** `/cards/:id/bury`

Enterra um card.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "buried": true,
    "updated_at": "2024-01-20T16:05:00Z"
  }
}
```

### 7.6 Desenterrar Card

**POST** `/cards/:id/unbury`

Desenterra um card.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "buried": false,
    "updated_at": "2024-01-20T16:05:00Z"
  }
}
```

### 7.7 Suspender Card

**POST** `/cards/:id/suspend`

Suspende um card.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "suspended": true,
    "updated_at": "2024-01-20T16:05:00Z"
  }
}
```

### 7.8 Dessuspender Card

**POST** `/cards/:id/unsuspend`

Dessuspende um card.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "suspended": false,
    "updated_at": "2024-01-20T16:05:00Z"
  }
}
```

### 7.9 Resetar Card

**POST** `/cards/:id/reset`

Reseta um card para estado inicial.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "type": "new",
  "preserve_history": true,
  "restore_position": false
}
```

**Tipos:**
- `new`: Reseta para new (preserva histórico)
- `forget`: Esquece completamente (remove histórico)
- `restore`: Restaura posição original

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "state": "new",
    "due": 0,
    "interval": 0,
    "ease": 2500,
    "lapses": 0,
    "reps": 0,
    "updated_at": "2024-01-20T16:05:00Z"
  }
}
```

### 7.10 Definir Data de Vencimento

**POST** `/cards/:id/set-due`

Define data de vencimento de um card.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "due": 1705766400000,
  "reschedule": false
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "due": 1705766400000,
    "updated_at": "2024-01-20T16:05:00Z"
  }
}
```

### 7.11 Listar Leeches

**GET** `/cards/leeches`

Lista cards identificados como leeches.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `deck_id` (integer, optional): Filtrar por deck
- `min_lapses` (integer, default: 8): Mínimo de lapses

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "note_id": 1,
      "deck_id": 1,
      "lapses": 10,
      "note": {
        "fields": {
          "Front": "Hello",
          "Back": "Olá"
        }
      }
    }
  ]
}
```

### 7.12 Reposicionar Cards

**POST** `/cards/reposition`

Reposiciona novos cards na fila.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "card_ids": [1, 2, 3],
  "new_position": 0,
  "shift_existing": true
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "repositioned_count": 3,
    "message": "Cards reposicionados com sucesso"
  }
}
```

### 7.13 Obter Posição de Card

**GET** `/cards/:id/position`

Retorna a posição atual de um card na fila de novos cards.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "card_id": 1,
    "position": 5,
    "total_new_cards": 20
  }
}
```

## 8. Sistema de Estudo

### 8.1 Overview do Deck

**GET** `/study/deck/:id/overview`

Retorna overview de um deck para estudo.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "deck_id": 1,
    "deck_name": "Default",
    "new_count": 10,
    "learning_count": 5,
    "review_count": 50,
    "buried_count": 2,
    "total_cards": 65,
    "estimated_time_minutes": 15
  }
}
```

### 8.2 Iniciar Sessão de Estudo

**POST** `/study/start`

Inicia uma sessão de estudo.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "deck_id": 1,
  "custom_study": false,
  "new_limit": null,
  "review_limit": null
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "session_id": "session_123",
    "deck_id": 1,
    "new_count": 10,
    "learning_count": 5,
    "review_count": 50,
    "started_at": "2024-01-20T16:00:00Z"
  }
}
```

### 8.3 Obter Próximo Card

**GET** `/study/next-card`

Retorna o próximo card para estudo.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `session_id` (string, optional): ID da sessão

**Response:** `200 OK`
```json
{
  "data": {
    "card_id": 1,
    "note_id": 1,
    "card_type_id": 0,
    "state": "new",
    "front": "<div>Hello</div>",
    "back": "<div>Hello</div><hr id=answer><div>Olá</div>",
    "styling": ".card { font-family: arial; }",
    "has_audio": true,
    "has_images": false,
    "siblings_count": 0,
    "is_buried": false
  }
}
```

**Response:** `204 No Content` (sem mais cards)

### 8.4 Responder Card

**POST** `/study/answer`

Registra resposta de um card.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "card_id": 1,
  "rating": 3,
  "time_ms": 5000,
  "session_id": "session_123"
}
```

**Ratings:**
- `1`: Again
- `2`: Hard
- `3`: Good
- `4`: Easy

**Response:** `200 OK`
```json
{
  "data": {
    "card_id": 1,
    "new_state": "review",
    "new_due": 1705852800000,
    "new_interval": 1,
    "new_ease": 2500,
    "next_card": {
      "card_id": 2,
      "state": "review",
      "front": "<div>World</div>"
    }
  }
}
```

### 8.5 Finalizar Sessão

**POST** `/study/end`

Finaliza uma sessão de estudo.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "session_id": "session_123"
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "session_id": "session_123",
    "total_cards": 15,
    "new_cards": 5,
    "learning_cards": 3,
    "review_cards": 7,
    "total_time_ms": 300000,
    "ended_at": "2024-01-20T16:30:00Z"
  }
}
```

### 8.6 Obter Card Anterior

**GET** `/study/previous-card`

Retorna informações do card anterior (Previous Card Info).

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `card_id` (integer): ID do card atual

**Response:** `200 OK`
```json
{
  "data": {
    "card_id": 0,
    "note_id": 0,
    "front": "<div>Previous</div>",
    "back": "<div>Previous Answer</div>",
    "last_review": "2024-01-20T15:45:00Z",
    "last_rating": 3
  }
}
```

**Response:** `404 Not Found` (sem card anterior)

### 8.7 Criar Cópia de Note

**POST** `/study/create-copy`

Cria uma cópia da note atual durante estudo.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "note_id": 1,
  "deck_id": 1
}
```

**Response:** `201 Created`
```json
{
  "data": {
    "note_id": 2,
    "guid": "550e8400-e29b-41d4-a716-446655440001",
    "created_at": "2024-01-20T16:00:00Z"
  }
}
```

### 8.8 Undo (Desfazer)

**POST** `/study/undo`

Desfaz a última operação durante estudo.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "session_id": "session_123"
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "operation": "answer",
    "card_id": 1,
    "reverted": true,
    "message": "Operação desfeita com sucesso"
  }
}
```

**Response:** `404 Not Found` (sem operação para desfazer)

### 8.9 Redo (Refazer)

**POST** `/study/redo`

Refaz a última operação desfeita.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "session_id": "session_123"
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "operation": "answer",
    "card_id": 1,
    "reapplied": true,
    "message": "Operação refeita com sucesso"
  }
}
```

**Response:** `404 Not Found` (sem operação para refazer)

### 8.10 Configurar Auto-Advance

**POST** `/study/auto-advance`

Configura auto-advance durante sessão de estudo.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "session_id": "session_123",
  "enabled": true,
  "question_seconds": 0,
  "answer_seconds": 5
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "enabled": true,
    "question_seconds": 0,
    "answer_seconds": 5,
    "message": "Auto-advance configurado"
  }
}
```

### 8.11 Iniciar Timebox

**POST** `/study/timebox/start`

Inicia uma sessão de timeboxing.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "session_id": "session_123",
  "time_limit_minutes": 25
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "timebox_id": "timebox_123",
    "time_limit_minutes": 25,
    "started_at": "2024-01-20T16:00:00Z",
    "ends_at": "2024-01-20T16:25:00Z"
  }
}
```

### 8.12 Finalizar Timebox

**POST** `/study/timebox/end`

Finaliza uma sessão de timeboxing e retorna estatísticas.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "timebox_id": "timebox_123"
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "timebox_id": "timebox_123",
    "time_limit_minutes": 25,
    "actual_time_minutes": 23,
    "cards_studied": 50,
    "new_cards": 10,
    "learning_cards": 5,
    "review_cards": 35,
    "ended_at": "2024-01-20T16:23:00Z"
  }
}
```

## 9. Note Types

### 9.1 Listar Note Types

**GET** `/note-types`

Lista todos os note types do usuário.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "name": "Basic",
      "fields": [
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
      ],
      "card_types": [
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
      ],
      "created_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-20T15:45:00Z"
    }
  ]
}
```

### 9.2 Criar Note Type

**POST** `/note-types`

Cria um novo note type.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Basic",
  "fields": [
    {
      "name": "Front",
      "ord": 0,
      "font": "Arial",
      "font_size": 20,
      "rtl": false,
      "sticky": false,
      "sort_field": true
    },
    {
      "name": "Back",
      "ord": 1,
      "font": "Arial",
      "font_size": 20,
      "rtl": false,
      "sticky": false,
      "sort_field": false
    }
  ],
  "card_types": [
    {
      "name": "Forward",
      "ord": 0,
      "front_template": "{{Front}}",
      "back_template": "{{FrontSide}}\n<hr id=answer>\n{{Back}}",
      "styling": ".card { font-family: arial; font-size: 20px; }",
      "browser_appearance": "{{Front}}"
    }
  ]
}
```

**Response:** `201 Created`
```json
{
  "data": {
    "id": 2,
    "name": "Basic",
    "created_at": "2024-01-20T16:00:00Z"
  }
}
```

### 9.3 Obter Note Type

**GET** `/note-types/:id`

Retorna um note type específico.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "name": "Basic",
    "fields": [...],
    "card_types": [...],
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-20T15:45:00Z"
  }
}
```

### 9.4 Atualizar Note Type

**PUT** `/note-types/:id`

Atualiza um note type existente.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Basic Updated",
  "fields": [...],
  "card_types": [...]
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "name": "Basic Updated",
    "updated_at": "2024-01-20T16:05:00Z"
  }
}
```

### 9.5 Excluir Note Type

**DELETE** `/note-types/:id`

Exclui um note type (apenas se não houver notes usando).

**Headers:** `Authorization: Bearer <token>`

**Response:** `204 No Content`

**Erros:**
- `409`: Note type está em uso

### 9.6 Clonar Note Type

**POST** `/note-types/:id/clone`

Clona um note type existente.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Basic Copy"
}
```

**Response:** `201 Created`
```json
{
  "data": {
    "id": 3,
    "name": "Basic Copy",
    "created_at": "2024-01-20T16:00:00Z"
  }
}
```

### 9.7 Preview de Card

**POST** `/note-types/:id/preview`

Gera preview de um card baseado em note type e campos.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "card_type_id": 0,
  "fields": {
    "Front": "Hello",
    "Back": "Olá"
  }
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "front": "<div>Hello</div>",
    "back": "<div>Hello</div><hr id=answer><div>Olá</div>",
    "styling": ".card { font-family: arial; font-size: 20px; }"
  }
}
```

## 10. Media

### 10.1 Upload de Media

**POST** `/media/upload`

Faz upload de um arquivo de media.

**Headers:** `Authorization: Bearer <token>`

**Content-Type:** `multipart/form-data`

**Form Data:**
- `file` (file): Arquivo de media
- `note_id` (integer, optional): Associar a uma note
- `field_name` (string, optional): Campo da note

**Response:** `201 Created`
```json
{
  "data": {
    "id": 1,
    "filename": "image.jpg",
    "hash": "abc123...",
    "size": 102400,
    "mime_type": "image/jpeg",
    "url": "/api/v1/media/1",
    "created_at": "2024-01-20T16:00:00Z"
  }
}
```

### 10.2 Obter Media

**GET** `/media/:id`

Retorna informações de um arquivo de media.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "filename": "image.jpg",
    "hash": "abc123...",
    "size": 102400,
    "mime_type": "image/jpeg",
    "url": "/api/v1/media/1",
    "created_at": "2024-01-20T16:00:00Z"
  }
}
```

### 10.3 Download de Media

**GET** `/media/:id/download`

Faz download do arquivo de media.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
- Content-Type: baseado no mime_type
- Content-Disposition: attachment; filename="image.jpg"

### 10.4 Excluir Media

**DELETE** `/media/:id`

Exclui um arquivo de media.

**Headers:** `Authorization: Bearer <token>`

**Response:** `204 No Content`

### 10.5 Verificar Media Não Utilizada

**GET** `/media/check`

Verifica e lista media não utilizada.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "unused_media": [
      {
        "id": 1,
        "filename": "unused.jpg",
        "size": 102400,
        "created_at": "2024-01-15T10:30:00Z"
      }
    ],
    "total_size": 102400,
    "count": 1
  }
}
```

### 10.6 Limpar Media Não Utilizada

**POST** `/media/cleanup`

Remove media não utilizada.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "media_ids": [1, 2, 3]
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "deleted_count": 3,
    "freed_space": 307200
  }
}
```

## 11. Busca

### 11.1 Busca Simples

**GET** `/search`

Busca simples de notes/cards.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `q` (string): Query de busca
- `type` (string, enum: `notes`, `cards`, default: `notes`): Tipo de resultado
- `limit` (integer, default: 20): Limite de resultados

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "type": "note",
      "fields": {
        "Front": "Hello",
        "Back": "Olá"
      },
      "tags": ["vocabulary"]
    }
  ],
  "total": 10
}
```

### 11.2 Busca Avançada

**POST** `/search/advanced`

Busca avançada usando sintaxe Anki.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "query": "deck:Default tag:vocabulary front:hello -tag:marked",
  "type": "notes",
  "limit": 20,
  "offset": 0
}
```

**Sintaxe de Busca:**
- `deck:name`: Filtrar por deck
- `tag:name`: Filtrar por tag
- `front:text`: Buscar em campo Front
- `back:text`: Buscar em campo Back
- `field:name:text`: Buscar em campo específico
- `flag:1`: Filtrar por flag
- `is:new`: Filtrar por estado
- `is:marked`: Filtrar por marked
- `is:suspended`: Filtrar por suspended
- `-tag:name`: Excluir tag
- `"exact phrase"`: Busca exata
- `*wildcard`: Wildcard

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "type": "note",
      "fields": {
        "Front": "Hello",
        "Back": "Olá"
      },
      "tags": ["vocabulary"]
    }
  ],
  "total": 10
}
```

### 11.3 Salvar Busca

**POST** `/search/saved`

Salva uma busca para uso futuro.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Vocabulary English",
  "query": "tag:vocabulary tag:english"
}
```

**Response:** `201 Created`
```json
{
  "data": {
    "id": 1,
    "name": "Vocabulary English",
    "query": "tag:vocabulary tag:english",
    "created_at": "2024-01-20T16:00:00Z"
  }
}
```

### 11.4 Listar Buscas Salvas

**GET** `/search/saved`

Lista buscas salvas.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "name": "Vocabulary English",
      "query": "tag:vocabulary tag:english",
      "created_at": "2024-01-20T16:00:00Z"
    }
  ]
}
```

## 12. Estatísticas

### 12.1 Estatísticas do Deck

**GET** `/stats/deck/:id`

Retorna estatísticas detalhadas de um deck.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `days` (integer, default: 30): Período em dias
- `include_graphs` (boolean, default: true): Incluir dados de gráficos

**Response:** `200 OK`
```json
{
  "data": {
    "deck_id": 1,
    "deck_name": "Default",
    "period_days": 30,
    "summary": {
      "total_cards": 100,
      "new_cards": 10,
      "learning_cards": 5,
      "review_cards": 50,
      "suspended_cards": 2,
      "total_notes": 65
    },
    "reviews": {
      "total": 500,
      "by_rating": {
        "again": 50,
        "hard": 100,
        "good": 300,
        "easy": 50
      },
      "average_time_ms": 5000,
      "total_time_ms": 2500000
    },
    "retention": {
      "1_day": 0.85,
      "7_days": 0.80,
      "30_days": 0.75
    },
    "graphs": {
      "reviews_per_day": [
        {"date": "2024-01-01", "count": 20},
        {"date": "2024-01-02", "count": 25}
      ],
      "retention_over_time": [...],
      "intervals_distribution": [...]
    }
  }
}
```

### 12.2 Estatísticas da Coleção

**GET** `/stats/collection`

Retorna estatísticas da coleção completa.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `days` (integer, default: 30): Período em dias

**Response:** `200 OK`
```json
{
  "data": {
    "summary": {
      "total_decks": 5,
      "total_cards": 500,
      "total_notes": 350,
      "total_reviews": 5000
    },
    "reviews": {
      "total": 5000,
      "average_per_day": 166.67,
      "by_rating": {...}
    },
    "retention": {
      "overall": 0.82
    }
  }
}
```

### 12.3 Estatísticas do Card

**GET** `/stats/card/:id`

Retorna estatísticas detalhadas de um card.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "card_id": 1,
    "total_reviews": 10,
    "first_review": "2024-01-15T10:00:00Z",
    "last_review": "2024-01-20T15:45:00Z",
    "average_time_ms": 5000,
    "total_time_ms": 50000,
    "ease_history": [2500, 2600, 2500, 2400, 2500],
    "interval_history": [1, 2, 4, 1, 2],
    "rating_history": [3, 3, 4, 2, 3],
    "review_history": [
      {
        "rating": 3,
        "interval": 1,
        "ease": 2500,
        "time_ms": 5000,
        "type": "review",
        "created_at": "2024-01-20T15:45:00Z"
      }
    ]
  }
}
```

## 13. Sincronização

### 13.1 Status de Sincronização

**GET** `/sync/status`

Retorna status de sincronização.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "last_sync": "2024-01-20T15:00:00Z",
    "last_sync_usn": 1000,
    "client_id": "client_123",
    "pending_changes": {
      "notes": 5,
      "cards": 10,
      "decks": 1,
      "media": 2
    },
    "server_changes": {
      "notes": 3,
      "cards": 8,
      "decks": 0,
      "media": 1
    }
  }
}
```

### 13.2 Upload (Enviar Mudanças)

**POST** `/sync/upload`

Envia mudanças locais para o servidor.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "client_id": "client_123",
  "last_sync_usn": 1000,
  "changes": {
    "notes": [...],
    "cards": [...],
    "decks": [...],
    "media": [...]
  }
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "usn": 1001,
    "conflicts": [],
    "message": "Sincronização concluída"
  }
}
```

### 13.3 Download (Receber Mudanças)

**POST** `/sync/download`

Recebe mudanças do servidor.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "client_id": "client_123",
  "last_sync_usn": 1000
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "usn": 1001,
    "changes": {
      "notes": [...],
      "cards": [...],
      "decks": [...],
      "media": [...]
    },
    "conflicts": []
  }
}
```

### 13.4 Sincronização Completa

**POST** `/sync/full`

Força sincronização completa (upload + download).

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "client_id": "client_123",
  "direction": "bidirectional"
}
```

**Directions:**
- `bidirectional`: Sincronização bidirecional
- `upload`: Apenas upload (sobrescreve servidor)
- `download`: Apenas download (sobrescreve local)

**Response:** `200 OK`
```json
{
  "data": {
    "usn": 1001,
    "uploaded": {
      "notes": 5,
      "cards": 10
    },
    "downloaded": {
      "notes": 3,
      "cards": 8
    },
    "conflicts": []
  }
}
```

## 14. Importação e Exportação

### 14.1 Importar Texto

**POST** `/import/text`

Importa notes de arquivo de texto.

**Headers:** `Authorization: Bearer <token>`

**Content-Type:** `multipart/form-data`

**Form Data:**
- `file` (file): Arquivo de texto (CSV, TSV)
- `note_type_id` (integer): ID do note type
- `deck_id` (integer): ID do deck
- `separator` (string, default: `\t`): Separador
- `first_field_mapping` (boolean, default: true): Primeira linha como headers
- `update_existing` (boolean, default: false): Atualizar duplicatas

**Response:** `200 OK`
```json
{
  "data": {
    "imported": 100,
    "updated": 5,
    "failed": 0,
    "errors": []
  }
}
```

### 14.2 Importar Package (.apkg)

**POST** `/import/apkg`

Importa deck package.

**Headers:** `Authorization: Bearer <token>`

**Content-Type:** `multipart/form-data`

**Form Data:**
- `file` (file): Arquivo .apkg
- `deck_id` (integer, optional): Deck de destino

**Response:** `200 OK`
```json
{
  "data": {
    "imported": {
      "decks": 1,
      "notes": 100,
      "cards": 150,
      "media": 10
    },
    "errors": []
  }
}
```

### 14.3 Importar Collection Package (.colpkg)

**POST** `/import/colpkg`

Importa collection package completo.

**Headers:** `Authorization: Bearer <token>`

**Content-Type:** `multipart/form-data`

**Form Data:**
- `file` (file): Arquivo .colpkg
- `create_backup` (boolean, default: true): Criar backup antes

**Response:** `200 OK`
```json
{
  "data": {
    "imported": {
      "decks": 5,
      "notes": 500,
      "cards": 750,
      "media": 50
    },
    "backup_created": true,
    "errors": []
  }
}
```

### 14.4 Exportar Deck

**GET** `/export/deck/:id`

Exporta um deck como package.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `format` (string, enum: `apkg`, `text`, default: `apkg`): Formato de exportação
- `include_scheduling` (boolean, default: true): Incluir informações de scheduling
- `include_media` (boolean, default: true): Incluir media

**Response:** `200 OK`
- Content-Type: `application/zip` (apkg) ou `text/plain` (text)
- Content-Disposition: attachment; filename="deck.apkg"

### 14.5 Exportar Coleção

**GET** `/export/collection`

Exporta coleção completa como package.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `format` (string, enum: `colpkg`, `apkg`, default: `colpkg`): Formato
- `include_scheduling` (boolean, default: true): Incluir scheduling
- `include_media` (boolean, default: true): Incluir media

**Response:** `200 OK`
- Content-Type: `application/zip`
- Content-Disposition: attachment; filename="collection.colpkg"

## 15. Preferências

### 15.1 Obter Preferências

**GET** `/preferences`

Retorna preferências globais do usuário.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "language": "pt-BR",
    "theme": "auto",
    "auto_sync": true,
    "next_day_starts_at": "04:00:00",
    "learn_ahead_limit": 20,
    "timebox_time_limit": 0,
    "video_driver": "auto",
    "ui_size": 1.0,
    "minimalist_mode": false,
    "reduce_motion": false,
    "paste_strips_formatting": false,
    "paste_images_as_png": false,
    "default_deck_behavior": "current_deck",
    "show_play_buttons": true,
    "interrupt_audio_on_answer": true,
    "show_remaining_count": true,
    "show_next_review_time": false,
    "spacebar_answers_card": true,
    "ignore_accents_in_search": false
  }
}
```

### 15.2 Atualizar Preferências

**PUT** `/preferences`

Atualiza preferências globais.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "language": "en-US",
  "theme": "dark",
  "auto_sync": false,
  "ui_size": 1.2
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "message": "Preferências atualizadas com sucesso"
  }
}
```

## 16. Backups

### 16.1 Listar Backups

**GET** `/backups`

Lista backups do usuário.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `type` (string, enum: `all`, `automatic`, `manual`, `pre_operation`, optional): Filtrar por tipo

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "filename": "backup_20240120_160000.colpkg",
      "size": 10485760,
      "type": "automatic",
      "created_at": "2024-01-20T16:00:00Z"
    }
  ]
}
```

### 16.2 Criar Backup

**POST** `/backups/create`

Cria um backup manual.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "type": "manual",
  "include_media": true
}
```

**Response:** `201 Created`
```json
{
  "data": {
    "id": 2,
    "filename": "backup_20240120_160500.colpkg",
    "size": 10485760,
    "type": "manual",
    "created_at": "2024-01-20T16:05:00Z"
  }
}
```

### 16.3 Restaurar Backup

**POST** `/backups/:id/restore`

Restaura um backup.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "create_backup_before": true
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "message": "Backup restaurado com sucesso",
    "backup_created": true
  }
}
```

### 16.4 Excluir Backup

**DELETE** `/backups/:id`

Exclui um backup.

**Headers:** `Authorization: Bearer <token>`

**Response:** `204 No Content`

### 16.5 Download de Backup

**GET** `/backups/:id/download`

Faz download de um backup.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
- Content-Type: `application/zip`
- Content-Disposition: attachment; filename="backup.colpkg"

## 17. Filtered Decks

### 17.1 Listar Filtered Decks

**GET** `/filtered-decks`

Lista filtered decks do usuário.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "name": "Review Overdue",
      "search_filter": "is:due",
      "second_filter": null,
      "limit_cards": 20,
      "order_by": "due",
      "reschedule": true,
      "last_rebuild_at": "2024-01-20T15:00:00Z",
      "created_at": "2024-01-15T10:30:00Z"
    }
  ]
}
```

### 17.2 Criar Filtered Deck

**POST** `/filtered-decks`

Cria um novo filtered deck.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Review Overdue",
  "search_filter": "is:due",
  "second_filter": null,
  "limit_cards": 20,
  "order_by": "due",
  "reschedule": true
}
```

**Response:** `201 Created`
```json
{
  "data": {
    "id": 2,
    "name": "Review Overdue",
    "created_at": "2024-01-20T16:00:00Z"
  }
}
```

### 17.3 Obter Filtered Deck

**GET** `/filtered-decks/:id`

Retorna um filtered deck específico.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "name": "Review Overdue",
    "search_filter": "is:due",
    "limit_cards": 20,
    "order_by": "due",
    "reschedule": true,
    "last_rebuild_at": "2024-01-20T15:00:00Z"
  }
}
```

### 17.4 Atualizar Filtered Deck

**PUT** `/filtered-decks/:id`

Atualiza um filtered deck.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Review Overdue Updated",
  "limit_cards": 30
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "name": "Review Overdue Updated",
    "updated_at": "2024-01-20T16:05:00Z"
  }
}
```

### 17.5 Reconstruir Filtered Deck

**POST** `/filtered-decks/:id/rebuild`

Reconstrói um filtered deck (aplica filtros novamente).

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "message": "Filtered deck reconstruído",
    "cards_added": 15,
    "cards_removed": 5
  }
}
```

### 17.6 Excluir Filtered Deck

**DELETE** `/filtered-decks/:id`

Exclui um filtered deck (retorna cards aos home decks).

**Headers:** `Authorization: Bearer <token>`

**Response:** `204 No Content`

## 18. Browser

### 18.1 Configuração do Browser

**GET** `/browser/config`

Retorna configuração do browser.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "visible_columns": ["note", "deck", "tags", "due", "interval", "ease"],
    "column_widths": {
      "note": 200,
      "deck": 150,
      "tags": 100
    },
    "sort_column": "due",
    "sort_direction": "asc"
  }
}
```

### 18.2 Atualizar Configuração do Browser

**PUT** `/browser/config`

Atualiza configuração do browser.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "visible_columns": ["note", "deck", "tags", "due"],
  "column_widths": {
    "note": 250,
    "deck": 150
  },
  "sort_column": "updated_at",
  "sort_direction": "desc"
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "message": "Configuração atualizada"
  }
}
```

## 19. Operações em Lote

### 19.1 Operações em Lote

**POST** `/batch/operations`

Executa operações em lote em múltiplos cards/notes.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "operation": "add_tags",
  "targets": {
    "type": "cards",
    "ids": [1, 2, 3]
  },
  "params": {
    "tags": ["new_tag"]
  }
}
```

**Operações Disponíveis:**
- `add_tags`: Adicionar tags
- `remove_tags`: Remover tags
- `set_tags`: Definir tags
- `change_deck`: Mover para outro deck
- `change_note_type`: Alterar note type
- `suspend`: Suspender cards
- `unsuspend`: Dessuspender cards
- `bury`: Enterrar cards
- `unbury`: Desenterrar cards
- `set_flag`: Definir flag
- `remove_flag`: Remover flag
- `toggle_mark`: Alternar marcação
- `delete`: Excluir

**Response:** `200 OK`
```json
{
  "data": {
    "operation": "add_tags",
    "affected_count": 3,
    "success": true
  }
}
```

### 19.2 Buscar e Substituir

**POST** `/batch/find-replace`

Busca e substitui texto em múltiplas notes.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "search_query": "deck:Default",
  "find": "Hello",
  "replace": "Hi",
  "field": "Front",
  "regex": false,
  "case_sensitive": false
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "matched_count": 10,
    "replaced_count": 10,
    "errors": []
  }
}
```

### 19.3 Limpar Tags Não Utilizadas

**POST** `/batch/clear-unused-tags`

Remove tags que não estão sendo usadas.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "removed_tags": ["old_tag1", "old_tag2"],
    "count": 2
  }
}
```

## 20. Flags

### 20.1 Listar Flags

**GET** `/flags`

Lista nomes customizados de flags.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": [
    {
      "flag_number": 1,
      "name": "Important",
      "color": "red"
    },
    {
      "flag_number": 2,
      "name": "Review",
      "color": "orange"
    }
  ]
}
```

### 20.2 Atualizar Nome de Flag

**PUT** `/flags/:number`

Atualiza nome customizado de uma flag.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Important"
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "flag_number": 1,
    "name": "Important",
    "updated_at": "2024-01-20T16:05:00Z"
  }
}
```

## 21. Shared Decks

### 21.1 Listar Shared Decks

**GET** `/shared-decks`

Lista decks compartilhados disponíveis.

**Headers:** `Authorization: Bearer <token>` (opcional)

**Query Parameters:**
- `category` (string, optional): Filtrar por categoria
- `search` (string, optional): Busca textual
- `sort` (string, enum: `popular`, `recent`, `rating`, default: `popular`): Ordenação
- `featured` (boolean, optional): Apenas featured

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "name": "English Vocabulary",
      "description": "1000 most common English words",
      "category": "Languages",
      "author": {
        "id": 10,
        "name": "John Doe"
      },
      "download_count": 1000,
      "rating_average": 4.5,
      "rating_count": 50,
      "tags": ["english", "vocabulary"],
      "is_featured": true,
      "package_size": 5242880,
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

### 21.2 Obter Shared Deck

**GET** `/shared-decks/:id`

Retorna informações detalhadas de um shared deck.

**Headers:** `Authorization: Bearer <token>` (opcional)

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "name": "English Vocabulary",
    "description": "1000 most common English words",
    "category": "Languages",
    "author": {
      "id": 10,
      "name": "John Doe"
    },
    "download_count": 1000,
    "rating_average": 4.5,
    "rating_count": 50,
    "tags": ["english", "vocabulary"],
    "is_featured": true,
    "package_size": 5242880,
    "preview": {
      "notes_count": 1000,
      "cards_count": 1500,
      "note_types": ["Basic", "Cloze"]
    },
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-20T15:45:00Z"
  }
}
```

### 21.3 Download de Shared Deck

**POST** `/shared-decks/:id/download`

Baixa e importa um shared deck.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "deck_id": null
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "imported": {
      "deck_id": 5,
      "notes": 1000,
      "cards": 1500,
      "media": 50
    },
    "message": "Deck importado com sucesso"
  }
}
```

### 21.4 Avaliar Shared Deck

**POST** `/shared-decks/:id/rate`

Avalia um shared deck.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "rating": 5,
  "comment": "Excelente deck!"
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "message": "Avaliação registrada"
  }
}
```

### 21.5 Compartilhar Deck

**POST** `/shared-decks`

Compartilha um deck do usuário.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "deck_id": 1,
  "name": "My English Vocabulary",
  "description": "Personal vocabulary deck",
  "category": "Languages",
  "tags": ["english", "vocabulary"],
  "is_public": true
}
```

**Response:** `201 Created`
```json
{
  "data": {
    "id": 2,
    "name": "My English Vocabulary",
    "created_at": "2024-01-20T16:00:00Z"
  }
}
```

## 22. Add-ons

### 22.1 Listar Add-ons

**GET** `/add-ons`

Lista add-ons instalados.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "code": "1234567890",
      "name": "Awesome Add-on",
      "version": "1.0.0",
      "enabled": true,
      "config": {},
      "installed_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-20T15:45:00Z"
    }
  ]
}
```

### 22.2 Instalar Add-on

**POST** `/add-ons/install`

Instala um add-on pelo código.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "code": "1234567890"
}
```

**Response:** `201 Created`
```json
{
  "data": {
    "id": 2,
    "code": "1234567890",
    "name": "Awesome Add-on",
    "version": "1.0.0",
    "enabled": true,
    "installed_at": "2024-01-20T16:00:00Z"
  }
}
```

### 22.3 Atualizar Add-on

**PUT** `/add-ons/:id`

Atualiza configurações de um add-on.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "enabled": false,
  "config": {
    "setting1": "value1"
  }
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "enabled": false,
    "updated_at": "2024-01-20T16:05:00Z"
  }
}
```

### 22.4 Desinstalar Add-on

**DELETE** `/add-ons/:id`

Desinstala um add-on.

**Headers:** `Authorization: Bearer <token>`

**Response:** `204 No Content`

## 23. Manutenção

### 23.1 Verificar Banco de Dados

**POST** `/maintenance/check-database`

Executa verificação de integridade do banco.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "rebuild": true,
  "optimize": true
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "status": "completed",
    "issues_found": 0,
    "issues_details": [],
    "execution_time_ms": 5000,
    "created_at": "2024-01-20T16:00:00Z"
  }
}
```

### 23.2 Listar Empty Cards

**GET** `/maintenance/empty-cards`

Lista cards vazios para limpeza.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "empty_cards": [
      {
        "card_id": 1,
        "note_id": 1,
        "deck_id": 1,
        "deck_name": "Default",
        "note_type_name": "Basic"
      }
    ],
    "count": 1
  }
}
```

### 23.3 Limpar Empty Cards

**POST** `/maintenance/cleanup-empty-cards`

Remove cards vazios.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "card_ids": [1, 2, 3]
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "deleted_count": 3
  }
}
```

### 23.4 Otimizar Banco de Dados

**POST** `/maintenance/optimize`

Otimiza índices e compacta banco de dados.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "message": "Banco de dados otimizado",
    "execution_time_ms": 10000
  }
}
```

## 24. Profiles (Perfis)

### 24.1 Listar Profiles

**GET** `/profiles`

Lista todos os perfis do usuário.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": [
    {
      "id": 1,
      "name": "Default",
      "ankiweb_sync_enabled": false,
      "ankiweb_username": null,
      "created_at": "2024-01-15T10:00:00Z",
      "updated_at": "2024-01-15T10:00:00Z"
    },
    {
      "id": 2,
      "name": "Work",
      "ankiweb_sync_enabled": true,
      "ankiweb_username": "user@example.com",
      "created_at": "2024-01-16T10:00:00Z",
      "updated_at": "2024-01-16T10:00:00Z"
    }
  ]
}
```

### 24.2 Criar Profile

**POST** `/profiles`

Cria um novo perfil.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "New Profile"
}
```

**Response:** `201 Created`
```json
{
  "data": {
    "id": 3,
    "name": "New Profile",
    "ankiweb_sync_enabled": false,
    "ankiweb_username": null,
    "created_at": "2024-01-20T10:00:00Z",
    "updated_at": "2024-01-20T10:00:00Z"
  }
}
```

### 24.3 Obter Profile

**GET** `/profiles/{profile_id}`

Obtém informações de um perfil específico.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "name": "Default",
    "ankiweb_sync_enabled": false,
    "ankiweb_username": null,
    "created_at": "2024-01-15T10:00:00Z",
    "updated_at": "2024-01-15T10:00:00Z"
  }
}
```

### 24.4 Atualizar Profile

**PUT** `/profiles/{profile_id}`

Atualiza um perfil existente.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Updated Profile Name",
  "ankiweb_sync_enabled": true,
  "ankiweb_username": "user@example.com"
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "id": 1,
    "name": "Updated Profile Name",
    "ankiweb_sync_enabled": true,
    "ankiweb_username": "user@example.com",
    "created_at": "2024-01-15T10:00:00Z",
    "updated_at": "2024-01-20T10:00:00Z"
  }
}
```

**Validação:**
- Se `ankiweb_sync_enabled` for `true`, sistema valida que apenas um perfil por usuário pode ter sincronização habilitada
- Se outro perfil já tem sincronização habilitada, retorna erro `DUPLICATE_ENTRY`

### 24.5 Excluir Profile

**DELETE** `/profiles/{profile_id}`

Exclui um perfil e toda sua coleção.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `confirm` (boolean, required): Confirmação de exclusão

**Response:** `200 OK`
```json
{
  "data": {
    "message": "Perfil excluído com sucesso"
  }
}
```

### 24.6 Alternar Profile

**POST** `/profiles/{profile_id}/switch`

Alterna para um perfil específico.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "message": "Perfil alternado com sucesso",
    "profile": {
      "id": 2,
      "name": "Work",
      "ankiweb_sync_enabled": true,
      "ankiweb_username": "user@example.com"
    }
  }
}
```

## 25. Self-Hosted Sync Server

### 25.1 Configurar Self-Hosted Sync Server

**PUT** `/sync/server/config`

Configura URL do servidor self-hosted.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "server_url": "https://sync.example.com",
  "verify_connection": true
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "message": "Servidor configurado com sucesso",
    "server_url": "https://sync.example.com",
    "connection_status": "connected"
  }
}
```

**Validação:**
- Se `verify_connection` for `true`, sistema tenta conectar ao servidor antes de salvar
- URL deve ser válida (HTTP ou HTTPS)
- Sistema valida que servidor responde corretamente

### 25.2 Testar Conexão com Self-Hosted Server

**POST** `/sync/server/test`

Testa conexão com servidor self-hosted configurado.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "server_url": "https://sync.example.com"
}
```

**Response:** `200 OK`
```json
{
  "data": {
    "status": "connected",
    "response_time_ms": 150,
    "server_version": "2.1.66"
  }
}
```

**Erros Possíveis:**
- `404 Not Found`: Servidor não encontrado
- `500 Server Error`: Erro no servidor
- `TIMEOUT`: Timeout na conexão

### 25.3 Obter Configuração do Servidor

**GET** `/sync/server/config`

Obtém configuração atual do servidor self-hosted.

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "server_url": "https://sync.example.com",
    "connection_status": "connected",
    "last_sync_at": "2024-01-20T10:00:00Z"
  }
}
```

### 25.4 Remover Configuração do Servidor

**DELETE** `/sync/server/config`

Remove configuração do servidor self-hosted (volta para AnkiWeb).

**Headers:** `Authorization: Bearer <token>`

**Response:** `200 OK`
```json
{
  "data": {
    "message": "Configuração removida. Usando AnkiWeb agora."
  }
}
```

## 26. WebSocket (Real-time)

### 24.1 Conexão WebSocket

**WS** `/ws`

Conexão WebSocket para atualizações em tempo real.

**Headers:** `Authorization: Bearer <token>`

**Eventos Enviados pelo Cliente:**
- `ping`: Manter conexão ativa

**Eventos Recebidos do Servidor:**
- `pong`: Resposta ao ping
- `sync_status`: Status de sincronização atualizado
- `card_updated`: Card foi atualizado
- `note_updated`: Note foi atualizada
- `deck_updated`: Deck foi atualizado

**Exemplo de Mensagem:**
```json
{
  "type": "card_updated",
  "data": {
    "card_id": 1,
    "due": 1705766400000,
    "state": "review"
  }
}
```

## 27. Erros Comuns

### 27.1 Códigos de Erro

| Código | Descrição |
|--------|-----------|
| `AUTH_REQUIRED` | Autenticação necessária |
| `AUTH_INVALID` | Token inválido ou expirado |
| `AUTH_FORBIDDEN` | Sem permissão para acessar recurso |
| `VALIDATION_ERROR` | Erro de validação |
| `NOT_FOUND` | Recurso não encontrado |
| `DUPLICATE_ENTRY` | Entrada duplicada |
| `INVALID_OPERATION` | Operação inválida |
| `RATE_LIMIT_EXCEEDED` | Rate limit excedido |
| `SERVER_ERROR` | Erro interno do servidor |

### 27.2 Exemplos de Respostas de Erro

**401 Unauthorized:**
```json
{
  "error": {
    "code": "AUTH_REQUIRED",
    "message": "Autenticação necessária",
    "timestamp": "2024-01-20T16:00:00Z"
  }
}
```

**422 Unprocessable Entity:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Erro de validação",
    "details": {
      "email": "Email inválido",
      "password": "Senha deve ter pelo menos 8 caracteres"
    },
    "timestamp": "2024-01-20T16:00:00Z"
  }
}
```

**404 Not Found:**
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Deck não encontrado",
    "timestamp": "2024-01-20T16:00:00Z"
  }
}
```

## 28. Considerações de Implementação

### 28.1 Performance

- Todas as listagens devem usar paginação
- Queries complexas devem ser otimizadas com índices
- Cachear resultados de estatísticas e overview
- Usar lazy loading para media

### 28.2 Segurança

- Validar todos os inputs
- Sanitizar dados antes de salvar
- Implementar rate limiting
- Proteger contra SQL injection e XSS
- Validar ownership de recursos

### 28.3 Versionamento

- Manter compatibilidade com versões anteriores
- Deprecar endpoints com aviso prévio
- Documentar mudanças entre versões

### 28.4 Documentação

- Manter documentação OpenAPI/Swagger atualizada
- Fornecer exemplos de requisições e respostas
- Documentar códigos de erro

---

**Versão:** 1.0  
**Última Atualização:** 2024-01-20

