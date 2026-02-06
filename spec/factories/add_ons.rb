# frozen_string_literal: true

FactoryBot.define do
  factory :add_on do
    user
    sequence(:code) { |n| "addon_#{n}" }
    sequence(:name) { |n| "Add-on #{n}" }
    version { "1.0.0" }
    enabled { true }
    config_json { {} }

    trait :disabled do
      enabled { false }
    end
  end
end
