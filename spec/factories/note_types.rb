# frozen_string_literal: true

FactoryBot.define do
  factory :note_type do
    user
    sequence(:name) { |n| "Note Type #{n}" }
    fields_json { [{ "name" => "Front", "ord" => 0 }, { "name" => "Back", "ord" => 1 }] }
    card_types_json { [{ "name" => "Forward", "ord" => 0 }] }
    templates_json { { "Front" => "{{Front}}", "Back" => "{{FrontSide}}<hr>{{Back}}", "Styling" => "" } }

    trait :with_reverse do
      card_types_json { [{ "name" => "Forward", "ord" => 0 }, { "name" => "Reverse", "ord" => 1 }] }
    end

    trait :cloze do
      sequence(:name) { |n| "Cloze #{n}" }
      fields_json { [{ "name" => "Text", "ord" => 0 }, { "name" => "Extra", "ord" => 1 }] }
      card_types_json { [{ "name" => "Cloze", "ord" => 0 }] }
      templates_json { { "Front" => "{{cloze:Text}}", "Back" => "{{cloze:Text}}<br>{{Extra}}", "Styling" => "" } }
    end

    trait :soft_deleted do
      deleted_at { Time.current }
    end
  end
end
