# frozen_string_literal: true

FactoryBot.define do
  factory :shared_deck do
    association :author, factory: :user
    sequence(:name) { |n| "Shared Deck #{n}" }
    sequence(:package_path) { |n| "shared/#{n}/deck_#{n}.apkg" }
    package_size { 2048 }

    trait :featured do
      is_featured { true }
    end

    trait :private do
      is_public { false }
    end

    trait :popular do
      download_count { 1000 }
    end

    trait :top_rated do
      rating_average { 4.8 }
      rating_count { 50 }
    end

    trait :soft_deleted do
      deleted_at { Time.current }
    end
  end
end
