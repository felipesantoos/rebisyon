source "https://rubygems.org"

ruby "3.3.0"

# Core Rails
gem "rails", "~> 7.2.2", ">= 7.2.2.1"
gem "pg", "~> 1.5"
gem "puma", ">= 6.0"
gem "bootsnap", require: false

# Asset Pipeline & Frontend
gem "sprockets-rails"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "jbuilder"

# Background Jobs, Caching & WebSockets (Rails 8 defaults)
gem "solid_queue"
gem "solid_cache"
gem "solid_cable"
gem "mission_control-jobs"

# Authentication
gem "devise", "~> 4.9"
gem "devise-jwt", "~> 0.12"

# Features
gem "pagy", "~> 9.0"
gem "ransack", "~> 4.0"
gem "chartkick", "~> 5.0"
gem "groupdate", "~> 6.0"
gem "rubyzip", "~> 2.3"
gem "mini_magick", "~> 5.0"
gem "image_processing", "~> 1.2"

# I18n
gem "rails-i18n", "~> 7.0"

# Windows timezone data
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false

  # Testing
  gem "rspec-rails", "~> 8.0"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.4"
  gem "shoulda-matchers", "~> 6.0"

  # Debugging
  gem "bullet"
end

group :development do
  gem "web-console"
  gem "letter_opener"
  gem "annotate"
end

group :test do
  gem "capybara", "~> 3.40"
  gem "cuprite", "~> 0.15"
  gem "simplecov", require: false
  gem "database_cleaner-active_record"
end