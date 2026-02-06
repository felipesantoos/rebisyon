# frozen_string_literal: true

FactoryBot.define do
  factory :undo_history do
    user
    operation_type { "edit_note" }
    operation_data { { "summary" => "Edited note", "details" => "Changed front field" } }

    trait :delete_note do
      operation_type { "delete_note" }
      operation_data { { "summary" => "Deleted note", "details" => "Removed note and cards" } }
    end

    trait :move_card do
      operation_type { "move_card" }
      operation_data { { "summary" => "Moved card", "details" => "Moved to new deck" } }
    end
  end
end
