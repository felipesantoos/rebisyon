# frozen_string_literal: true

require "rails_helper"

RSpec.describe Review, type: :model do
  describe "associations" do
    it { should belong_to(:card) }
  end

  describe "validations" do
    subject { build(:review) }

    it { should validate_presence_of(:rating) }
    it { should validate_inclusion_of(:rating).in_range(1..4) }
    it { should validate_presence_of(:interval) }
    it { should validate_presence_of(:ease) }
    it { should validate_presence_of(:time_ms) }
    it { should validate_numericality_of(:time_ms).is_greater_than(0) }
    it { should validate_presence_of(:type) }
  end

  describe "enums" do
    it "defines type enum" do
      expect(Review.types).to eq(
        "learn" => "learn",
        "review" => "review",
        "relearn" => "relearn",
        "cram" => "cram"
      )
    end
  end
end
