# frozen_string_literal: true

# Pagy configuration
# See https://ddnexus.github.io/pagy/docs/how-to/

# Default items per page
Pagy::DEFAULT[:items] = 25

# Default page parameter
Pagy::DEFAULT[:page_param] = :page

# Overflow handling
Pagy::DEFAULT[:overflow] = :last_page

# Enable Turbo Stream support for Hotwire
require "pagy/extras/overflow"
require "pagy/extras/metadata"
