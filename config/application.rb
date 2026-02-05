require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Rebisyon
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Use structure.sql for complex PostgreSQL features (enums, triggers, views)
    config.active_record.schema_format = :sql

    # Default timezone
    config.time_zone = "America/Sao_Paulo"
    config.active_record.default_timezone = :utc

    # Default locale
    config.i18n.default_locale = :"pt-BR"
    config.i18n.available_locales = %i[en pt-BR]
    config.i18n.fallbacks = true

    # Generators configuration
    config.generators do |g|
      g.test_framework :rspec,
                       fixtures: true,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: false,
                       request_specs: true
      g.fixture_replacement :factory_bot, dir: "spec/factories"
      g.system_tests = nil
    end

    # Active Job backend
    config.active_job.queue_adapter = :solid_queue

    # Autoload services directory
    config.autoload_paths << Rails.root.join("app/services")
  end
end
