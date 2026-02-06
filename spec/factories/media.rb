# frozen_string_literal: true

FactoryBot.define do
  factory :medium do
    user
    sequence(:filename) { |n| "file_#{n}.jpg" }
    size { 1024 }
    mime_type { "image/jpeg" }
    sequence(:storage_path) { |n| "media/#{n}/file_#{n}.jpg" }

    after(:build) do |medium, evaluator|
      medium.write_attribute(:hash, Digest::SHA256.hexdigest("file_#{medium.filename}"))
    end

    trait :audio do
      sequence(:filename) { |n| "audio_#{n}.mp3" }
      mime_type { "audio/mpeg" }
    end

    trait :video do
      sequence(:filename) { |n| "video_#{n}.mp4" }
      mime_type { "video/mp4" }
    end

    trait :soft_deleted do
      deleted_at { Time.current }
    end
  end
end
