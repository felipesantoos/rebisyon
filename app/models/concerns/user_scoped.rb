# frozen_string_literal: true

# Provides user ownership scoping for models that belong to a user.
#
# When included, adds:
# - for_user scope to filter records by user
# - belongs_to :user association (optional, can be skipped)
#
# @example
#   class Deck < ApplicationRecord
#     include UserScoped
#   end
#
#   Deck.for_user(current_user)  # Returns decks belonging to current_user
module UserScoped
  extend ActiveSupport::Concern

  included do
    belongs_to :user

    # Scope to filter records by user
    scope :for_user, ->(user) { where(user_id: user.id) }

    # Validates user presence
    validates :user, presence: true
  end
end
