# frozen_string_literal: true

FactoryBot.define do
  factory :filtered_deck do
    user
    sequence(:name) { |n| "Filtered Deck #{n}" }
    search_filter { "is:due" }
    limit_cards { 20 }
    order_by { "due" }

    trait :soft_deleted do
      deleted_at { Time.current }
    end
  end
end
