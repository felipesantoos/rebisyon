# frozen_string_literal: true

FactoryBot.define do
  factory :deck do
    user
    sequence(:name) { |n| "Deck #{n}" }
    parent { nil }
    options_json { {} }

    trait :with_parent do
      association :parent, factory: :deck
    end

    trait :soft_deleted do
      deleted_at { Time.current }
    end
  end
end
