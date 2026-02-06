# frozen_string_literal: true

FactoryBot.define do
  factory :sync_meta do
    user
    sequence(:client_id) { |n| "client_#{n}" }
    last_sync_usn { 0 }
  end
end
