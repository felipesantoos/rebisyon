# frozen_string_literal: true

require "rails_helper"

RSpec.describe SharedDeck, type: :model do
  describe "associations" do
    it { should belong_to(:author).class_name("User") }
    it { should have_many(:shared_deck_ratings).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:shared_deck) }

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }
    it { should validate_presence_of(:package_path) }
    it { should validate_length_of(:package_path).is_at_most(512) }
    it { should validate_presence_of(:package_size) }
    it { should validate_numericality_of(:package_size).is_greater_than(0) }
    it { should validate_numericality_of(:rating_average).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(5).allow_nil }
  end

  describe "soft delete" do
    let!(:shared_deck) { create(:shared_deck) }

    it "supports soft delete" do
      shared_deck.soft_delete!
      expect(shared_deck.soft_deleted?).to be true
      expect(SharedDeck.where(id: shared_deck.id)).to be_empty
    end

    it "can be restored" do
      shared_deck.soft_delete!
      shared_deck.restore!
      expect(shared_deck.soft_deleted?).to be false
    end

    it "is accessible via with_deleted" do
      shared_deck.soft_delete!
      expect(SharedDeck.with_deleted.where(id: shared_deck.id)).to exist
    end
  end

  describe "scopes" do
    describe ".featured" do
      it "returns only featured decks" do
        featured = create(:shared_deck, :featured)
        _regular = create(:shared_deck)
        expect(SharedDeck.featured).to contain_exactly(featured)
      end
    end

    describe ".public_decks" do
      it "returns only public decks" do
        public_deck = create(:shared_deck)
        _private = create(:shared_deck, :private)
        expect(SharedDeck.public_decks).to contain_exactly(public_deck)
      end
    end

    describe ".popular" do
      it "orders by download_count desc" do
        less = create(:shared_deck, download_count: 10)
        more = create(:shared_deck, download_count: 100)
        expect(SharedDeck.popular).to eq([more, less])
      end
    end

    describe ".top_rated" do
      it "orders by rating_average desc" do
        low = create(:shared_deck, rating_average: 2.0)
        high = create(:shared_deck, rating_average: 4.5)
        expect(SharedDeck.top_rated).to eq([high, low])
      end
    end
  end
end
