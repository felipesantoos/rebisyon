# frozen_string_literal: true

require "rails_helper"

RSpec.describe SharedDeckRating, type: :model do
  describe "associations" do
    it { should belong_to(:shared_deck) }
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { build(:shared_deck_rating) }

    it { should validate_presence_of(:rating) }
    it { should validate_inclusion_of(:rating).in_range(1..5) }
    it { should validate_uniqueness_of(:shared_deck_id).scoped_to(:user_id) }
  end
end
