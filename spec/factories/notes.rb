# frozen_string_literal: true

FactoryBot.define do
  factory :note do
    user
    association :note_type
    guid { SecureRandom.uuid }
    fields_json { { "Front" => "Question", "Back" => "Answer" } }
    tags { ["default"] }

    trait :marked do
      marked { true }
    end

    trait :with_tags do
      tags { %w[vocabulary grammar] }
    end

    trait :soft_deleted do
      deleted_at { Time.current }
    end
  end
end
