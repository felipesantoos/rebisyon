# frozen_string_literal: true

FactoryBot.define do
  factory :backup do
    user
    sequence(:filename) { |n| "backup_#{n}.apkg" }
    sequence(:storage_path) { |n| "backups/#{n}/backup_#{n}.apkg" }
    size { 1024 }
    backup_type { "automatic" }

    trait :manual do
      backup_type { "manual" }
    end

    trait :pre_operation do
      backup_type { "pre_operation" }
    end
  end
end
