# frozen_string_literal: true

class SharedDeck < ApplicationRecord
  include SoftDeletable

  belongs_to :author, class_name: "User"
  has_many :shared_deck_ratings, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :package_path, presence: true, length: { maximum: 512 }
  validates :package_size, presence: true, numericality: { greater_than: 0 }
  validates :rating_average, numericality: { greater_than_or_equal_to: 0,
            less_than_or_equal_to: 5 }, allow_nil: true

  scope :featured, -> { where(is_featured: true) }
  scope :public_decks, -> { where(is_public: true) }
  scope :popular, -> { order(download_count: :desc) }
  scope :top_rated, -> { order(rating_average: :desc) }
end
