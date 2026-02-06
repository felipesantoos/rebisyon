# frozen_string_literal: true

class FilteredDeck < ApplicationRecord
  include SoftDeletable
  include UserScoped

  validates :name, presence: true, length: { maximum: 255 }
  validates :search_filter, presence: true
  validates :limit_cards, presence: true, numericality: { greater_than: 0 }
  validates :order_by, presence: true, length: { maximum: 50 }

  scope :ordered, -> { order(:name) }
end
