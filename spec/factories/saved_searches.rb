# frozen_string_literal: true

FactoryBot.define do
  factory :saved_search do
    user
    sequence(:name) { |n| "Search #{n}" }
    search_query { "deck:Default" }

    trait :soft_deleted do
      deleted_at { Time.current }
    end
  end
end
