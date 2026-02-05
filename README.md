# Rebisyon

A full-stack Ruby on Rails 8 monolith implementing an Anki-like spaced repetition system for efficient learning and memorization.

![Ruby](https://img.shields.io/badge/Ruby-3.3.0-red)
![Rails](https://img.shields.io/badge/Rails-7.2-red)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16+-blue)

## Features

- 📚 **Spaced Repetition**: SM-2 and FSRS algorithms for optimal review scheduling
- 🗂️ **Deck Management**: Hierarchical deck organization with customizable options
- 📝 **Flexible Note Types**: Create custom note types with templates and fields
- 🔍 **Advanced Search**: Anki-compatible search syntax
- 📊 **Statistics**: Track your learning progress with detailed charts
- 🔄 **Import/Export**: APKG and CSV support for deck sharing
- 🌐 **Localization**: English and Brazilian Portuguese support

## Tech Stack

- **Framework**: Ruby on Rails 7.2
- **Database**: PostgreSQL 16+
- **Frontend**: Hotwire (Turbo + Stimulus)
- **Authentication**: Devise + devise-jwt
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **WebSockets**: Solid Cable
- **Testing**: RSpec, FactoryBot, Capybara, Cuprite

## Prerequisites

- Ruby 3.3.0
- PostgreSQL 16+

Or use Docker (recommended for quick setup).

## Setup

### Option A: Docker Setup (Recommended)

The easiest way to get started is using Docker.

**1. Start PostgreSQL with Docker:**

```bash
# Start only the database
docker compose up -d postgres

# Wait for it to be healthy
docker compose ps
```

**2. Install dependencies and setup Rails:**

```bash
bundle install
```

**3. Create and migrate database:**

```bash
# Set environment variables for Docker
export POSTGRES_HOST=localhost
export POSTGRES_USER=rebisyon
export POSTGRES_PASSWORD=rebisyon

# Create and migrate
bin/rails db:create db:migrate db:seed
```

**4. Start the server:**

```bash
bin/dev
```

Visit `http://localhost:3000` to access the application.

#### Full Docker Setup (Rails + PostgreSQL)

To run everything in Docker:

```bash
# Start all services
docker compose --profile full up -d
```

> **Note**: This app uses Rails 8's Solid Queue, Solid Cache, and Solid Cable (all database-backed). No Redis required!

### Option B: Local Setup

**1. Clone the repository:**

```bash
git clone https://github.com/yourusername/rebisyon.git
cd rebisyon
```

**2. Install dependencies:**

```bash
bundle install
```

**3. Create PostgreSQL database:**

Make sure PostgreSQL is running locally, then:

```bash
bin/rails db:create db:migrate db:seed
```

**4. Start the server:**

```bash
bin/dev
```

Visit `http://localhost:3000` to access the application.

## Development

### Running tests

```bash
bundle exec rspec
```

### Running linters

```bash
bin/rubocop
bin/brakeman
```

### Database migrations

```bash
bin/rails db:migrate
```

## Project Structure

```
app/
├── controllers/
│   ├── api/v1/           # JWT-authenticated JSON API
│   ├── concerns/         # Shared controller concerns
│   └── users/            # Devise controllers
├── models/
│   ├── concerns/         # SoftDeletable, UserScoped
│   ├── user.rb
│   └── user_preference.rb
├── services/
│   ├── scheduling/       # SM-2 and FSRS schedulers
│   ├── study/            # Session management
│   ├── cards/            # Card generation
│   └── users/            # User setup
├── views/
│   ├── layouts/          # Application layouts
│   ├── dashboard/        # Dashboard views
│   └── devise/           # Authentication views
└── javascript/
    └── controllers/      # Stimulus controllers

config/
├── routes.rb             # Application routes
├── locales/              # I18n translations
└── initializers/
    └── devise.rb         # Devise + JWT config

db/
├── migrate/              # Database migrations
└── structure.sql         # PostgreSQL schema

spec/
├── factories/            # FactoryBot factories
├── models/               # Model specs
├── requests/             # Request specs
└── system/               # System tests
```

## API Documentation

### Authentication

The API uses JWT tokens for authentication.

**Sign In**
```bash
POST /api/v1/auth/sign_in
Content-Type: application/json

{
  "user": {
    "email": "user@example.com",
    "password": "password123"
  }
}
```

The JWT token is returned in the `Authorization` header.

**Sign Out**
```bash
DELETE /api/v1/auth/sign_out
Authorization: Bearer <token>
```

### Protected Endpoints

Include the JWT token in the `Authorization` header:

```bash
GET /api/v1/decks
Authorization: Bearer <token>
```

## Docker Commands

```bash
# Start only PostgreSQL
docker compose up -d postgres

# Start full stack (Rails + PostgreSQL)
docker compose --profile full up -d

# View logs
docker compose logs -f postgres
docker compose logs -f web

# Stop all services
docker compose down

# Stop and remove volumes (WARNING: deletes data)
docker compose down -v

# Rebuild Rails image after Gemfile changes
docker compose build web
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection URL | - |
| `POSTGRES_HOST` | PostgreSQL host | `localhost` |
| `POSTGRES_PORT` | PostgreSQL port | `5432` |
| `POSTGRES_USER` | PostgreSQL username | `rebisyon` |
| `POSTGRES_PASSWORD` | PostgreSQL password | `rebisyon` |
| `POSTGRES_DB` | Database name | `rebisyon_development` |
| `DEVISE_JWT_SECRET_KEY` | JWT signing secret | - |
| `RAILS_MASTER_KEY` | Rails credentials key | - |
| `SECRET_KEY_BASE` | Rails secret key | - |

## Roadmap

See [Implementation Plan](docs/adaptive-beaming-hejlsberg.md) for the detailed development roadmap.

### Phase 1 ✅
- [x] Project bootstrap
- [x] User authentication (Devise + JWT)
- [x] User preferences
- [x] Dashboard shell

### Phase 2 (In Progress)
- [ ] Deck CRUD with hierarchy
- [ ] Note Types with templates
- [ ] Deck options presets

### Phase 3
- [ ] Notes and Cards
- [ ] Browser interface
- [ ] Search functionality

### Phase 4
- [ ] Study sessions
- [ ] SM-2 algorithm
- [ ] Daily limits

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Anki](https://apps.ankiweb.net/) - The original spaced repetition software
- [SuperMemo](https://www.supermemo.com/) - SM-2 algorithm creators
- [FSRS](https://github.com/open-spaced-repetition/fsrs4anki) - Free Spaced Repetition Scheduler
