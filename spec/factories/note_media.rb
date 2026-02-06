# frozen_string_literal: true

FactoryBot.define do
  factory :note_medium do
    association :note
    association :medium
    field_name { "Front" }
  end
end
