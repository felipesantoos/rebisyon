# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    confirmed_at { Time.current }

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :soft_deleted do
      deleted_at { Time.current }
    end

    trait :with_preferences do
      after(:create) do |user|
        create(:user_preference, user: user)
      end
    end
  end
end
