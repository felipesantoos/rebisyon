# frozen_string_literal: true

class SharedDeckRating < ApplicationRecord
  belongs_to :shared_deck
  belongs_to :user

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :shared_deck_id, uniqueness: { scope: :user_id }
end
