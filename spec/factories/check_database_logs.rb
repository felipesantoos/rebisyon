# frozen_string_literal: true

FactoryBot.define do
  factory :check_database_log do
    user
    status { "completed" }
    issues_found { 0 }

    trait :with_issues do
      issues_found { 3 }
      issues_details { { "errors" => ["Missing media", "Orphan cards", "Invalid template"] } }
    end

    trait :running do
      status { "running" }
    end

    trait :failed do
      status { "failed" }
    end
  end
end
