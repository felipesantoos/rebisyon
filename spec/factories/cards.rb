# frozen_string_literal: true

FactoryBot.define do
  factory :card do
    association :note
    association :deck
    card_type_id { 0 }
    state { :new }
    due { 0 }
    interval { 0 }
    ease { 2500 }
    lapses { 0 }
    reps { 0 }
    position { 0 }
    flag { 0 }
    suspended { false }
    buried { false }

    trait :learning do
      state { :learn }
      due { (Time.current.to_f * 1000).to_i }
    end

    trait :review do
      state { :review }
      due { (Time.current.to_f * 1000).to_i + 86_400_000 }
      interval { 1 }
      reps { 1 }
    end

    trait :relearning do
      state { :relearn }
      due { (Time.current.to_f * 1000).to_i }
      lapses { 1 }
    end

    trait :suspended do
      suspended { true }
    end

    trait :buried do
      buried { true }
    end

    trait :flagged do
      flag { 1 }
    end

    trait :leech do
      lapses { 8 }
    end
  end
end
