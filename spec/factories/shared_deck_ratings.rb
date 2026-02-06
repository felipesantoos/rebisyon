# frozen_string_literal: true

FactoryBot.define do
  factory :shared_deck_rating do
    shared_deck
    user
    rating { 4 }
    comment { "Great deck!" }
  end
end
