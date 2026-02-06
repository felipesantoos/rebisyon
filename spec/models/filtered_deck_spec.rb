# frozen_string_literal: true

require "rails_helper"

RSpec.describe FilteredDeck, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { build(:filtered_deck) }

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }
    it { should validate_presence_of(:search_filter) }
    it { should validate_presence_of(:limit_cards) }
    it { should validate_numericality_of(:limit_cards).is_greater_than(0) }
    it { should validate_presence_of(:order_by) }
    it { should validate_length_of(:order_by).is_at_most(50) }
  end

  describe "soft delete" do
    let(:user) { create(:user) }
    let!(:filtered_deck) { create(:filtered_deck, user: user) }

    it "supports soft delete" do
      filtered_deck.soft_delete!
      expect(filtered_deck.soft_deleted?).to be true
      expect(FilteredDeck.where(id: filtered_deck.id)).to be_empty
    end

    it "can be restored" do
      filtered_deck.soft_delete!
      filtered_deck.restore!
      expect(filtered_deck.soft_deleted?).to be false
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }

    describe ".ordered" do
      it "orders by name" do
        z = create(:filtered_deck, user: user, name: "Zebra")
        a = create(:filtered_deck, user: user, name: "Alpha")
        expect(user.filtered_decks.ordered).to eq([a, z])
      end
    end

    describe ".for_user" do
      it "returns filtered decks for specified user" do
        deck = create(:filtered_deck, user: user)
        _other = create(:filtered_deck)
        expect(FilteredDeck.for_user(user)).to contain_exactly(deck)
      end
    end
  end
end
