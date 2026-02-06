# frozen_string_literal: true

FactoryBot.define do
  factory :review do
    association :card
    rating { 3 }
    interval { 1 }
    ease { 2500 }
    time_ms { 5000 }
    review_type { :learn }

    trait :again do
      rating { 1 }
    end

    trait :hard do
      rating { 2 }
    end

    trait :good do
      rating { 3 }
    end

    trait :easy do
      rating { 4 }
    end

    trait :review_type do
      review_type { :review }
    end
  end
end
