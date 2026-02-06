# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPreference, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { build(:user_preference) }

    it { should validate_presence_of(:language) }
    it { should validate_inclusion_of(:language).in_array(%w[en pt-BR]) }
    it { should validate_numericality_of(:learn_ahead_limit).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:timebox_time_limit).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:ui_size).is_greater_than(0).is_less_than_or_equal_to(3.0) }
    it { should validate_inclusion_of(:default_deck_behavior).in_array(%w[current_deck last_deck_used_to_add first_field]) }
  end

  describe "enums" do
    it "defines theme enum" do
      expect(UserPreference.themes).to eq(
        "light" => "light",
        "dark" => "dark",
        "auto" => "auto"
      )
    end
  end

  describe "#day_rollover_time" do
    let(:preference) { build(:user_preference, next_day_starts_at: "04:00:00") }

    it "returns the next day start time" do
      expect(preference.day_rollover_time).to be_a(Time)
    end
  end
end
