# frozen_string_literal: true

FactoryBot.define do
  factory :deletion_log do
    user
    object_type { "note" }
    sequence(:object_id) { |n| n }
    deleted_at { Time.current }
    object_data { {} }

    trait :card_deletion do
      object_type { "card" }
    end

    trait :deck_deletion do
      object_type { "deck" }
    end
  end
end
