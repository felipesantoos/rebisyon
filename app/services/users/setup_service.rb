# frozen_string_literal: true

module Users
  # Sets up default configuration for new users.
  #
  # Creates:
  # - User preferences with default values
  # - Default deck named "Default"
  # - Default note types (Basic, Basic+Reversed, Cloze)
  #
  # @example
  #   Users::SetupService.new(user).call
  class SetupService
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def call
      ActiveRecord::Base.transaction do
        create_user_preference
        create_default_deck
        create_default_note_types
      end
    end

    private

    def create_user_preference
      user.create_user_preference!(
        language: "pt-BR",
        theme: "auto"
      )
    end

    def create_default_deck
      user.decks.create!(name: "Default")
    end

    def create_default_note_types
      create_basic_note_type
      create_basic_reversed_note_type
      create_basic_optional_reversed_note_type
      create_basic_type_in_answer_note_type
      create_cloze_note_type
    end

    def create_basic_note_type
      user.note_types.create!(
        name: "Basic",
        fields_json: [
          { "name" => "Front", "ord" => 0 },
          { "name" => "Back", "ord" => 1 }
        ],
        card_types_json: [
          { "name" => "Card 1", "ord" => 0 }
        ],
        templates_json: {
          "Card 1" => "{{Front}}",
          "Card 1 Back" => "{{FrontSide}}<hr id=answer>{{Back}}",
          "Styling" => ".card { font-family: arial; font-size: 20px; text-align: center; color: black; background-color: white; }"
        }
      )
    end

    def create_basic_reversed_note_type
      user.note_types.create!(
        name: "Basic (and reversed card)",
        fields_json: [
          { "name" => "Front", "ord" => 0 },
          { "name" => "Back", "ord" => 1 }
        ],
        card_types_json: [
          { "name" => "Card 1", "ord" => 0 },
          { "name" => "Card 2", "ord" => 1 }
        ],
        templates_json: {
          "Card 1" => "{{Front}}",
          "Card 1 Back" => "{{FrontSide}}<hr id=answer>{{Back}}",
          "Card 2" => "{{Back}}",
          "Card 2 Back" => "{{FrontSide}}<hr id=answer>{{Front}}",
          "Styling" => ".card { font-family: arial; font-size: 20px; text-align: center; color: black; background-color: white; }"
        }
      )
    end

    def create_basic_optional_reversed_note_type
      user.note_types.create!(
        name: "Basic (optional reversed card)",
        fields_json: [
          { "name" => "Front", "ord" => 0 },
          { "name" => "Back", "ord" => 1 }
        ],
        card_types_json: [
          { "name" => "Card 1", "ord" => 0 },
          { "name" => "Card 2", "ord" => 1 }
        ],
        templates_json: {
          "Card 1" => "{{Front}}",
          "Card 1 Back" => "{{FrontSide}}<hr id=answer>{{Back}}",
          "Card 2" => "{{#Back}}{{Back}}{{/Back}}",
          "Card 2 Back" => "{{FrontSide}}<hr id=answer>{{Front}}",
          "Styling" => ".card { font-family: arial; font-size: 20px; text-align: center; color: black; background-color: white; }"
        }
      )
    end

    def create_basic_type_in_answer_note_type
      user.note_types.create!(
        name: "Basic (type in the answer)",
        fields_json: [
          { "name" => "Front", "ord" => 0 },
          { "name" => "Back", "ord" => 1 }
        ],
        card_types_json: [
          { "name" => "Card 1", "ord" => 0 }
        ],
        templates_json: {
          "Card 1" => "{{Front}}<br>{{type:Back}}",
          "Card 1 Back" => "{{FrontSide}}<hr id=answer>{{Back}}",
          "Styling" => ".card { font-family: arial; font-size: 20px; text-align: center; color: black; background-color: white; }"
        }
      )
    end

    def create_cloze_note_type
      user.note_types.create!(
        name: "Cloze",
        fields_json: [
          { "name" => "Text", "ord" => 0 },
          { "name" => "Back Extra", "ord" => 1 }
        ],
        card_types_json: [
          { "name" => "Cloze", "ord" => 0 }
        ],
        templates_json: {
          "Cloze" => "{{cloze:Text}}",
          "Cloze Back" => "{{cloze:Text}}<br>{{Back Extra}}",
          "Styling" => ".card { font-family: arial; font-size: 20px; text-align: center; color: black; background-color: white; } .cloze { font-weight: bold; color: blue; }"
        }
      )
    end
  end
end
