# frozen_string_literal: true

# Provides Pagy pagination helpers for controllers.
#
# @example
#   class DecksController < ApplicationController
#     include Paginatable
#
#     def index
#       @pagy, @decks = paginate(current_user.decks)
#     end
#   end
module Paginatable
  extend ActiveSupport::Concern

  include Pagy::Backend

  DEFAULT_PAGE_SIZE = 25
  MAX_PAGE_SIZE = 100

  private

  # Paginates a collection with optional custom page size
  # @param collection [ActiveRecord::Relation] The collection to paginate
  # @param items [Integer] Number of items per page (default: 25)
  # @return [Array] [Pagy, Array] Pagy object and paginated records
  def paginate(collection, items: DEFAULT_PAGE_SIZE)
    items = [ items.to_i, MAX_PAGE_SIZE ].min
    items = DEFAULT_PAGE_SIZE if items < 1

    pagy(collection, items: items)
  end

  # Returns the requested page number
  def page_param
    params[:page]&.to_i || 1
  end
end
