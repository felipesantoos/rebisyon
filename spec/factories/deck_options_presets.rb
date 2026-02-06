# frozen_string_literal: true

FactoryBot.define do
  factory :deck_options_preset do
    user
    sequence(:name) { |n| "Preset #{n}" }
    options_json { {} }

    trait :with_custom_limits do
      options_json { { "new_per_day" => 30, "reviews_per_day" => 300 } }
    end

    trait :soft_deleted do
      deleted_at { Time.current }
    end
  end
end
