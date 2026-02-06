# frozen_string_literal: true

FactoryBot.define do
  factory :flag_name do
    user
    sequence(:flag_number) { |n| ((n - 1) % 7) + 1 }
    sequence(:name) { |n| "Flag #{n}" }
  end
end
