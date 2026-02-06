# frozen_string_literal: true

FactoryBot.define do
  factory :profile do
    user
    sequence(:name) { |n| "Profile #{n}" }
    ankiweb_sync_enabled { false }

    trait :with_ankiweb do
      ankiweb_sync_enabled { true }
      sequence(:ankiweb_username) { |n| "ankiuser#{n}" }
    end

    trait :soft_deleted do
      deleted_at { Time.current }
    end
  end
end
