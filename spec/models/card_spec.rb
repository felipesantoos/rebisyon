# frozen_string_literal: true

require "rails_helper"

RSpec.describe Card, type: :model do
  describe "associations" do
    it { should belong_to(:note) }
    it { should belong_to(:deck) }
    it { should belong_to(:home_deck).class_name("Deck").optional }
    it { should have_many(:reviews).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:card) }

    it { should validate_presence_of(:card_type_id) }
    it { should validate_presence_of(:due) }
    it { should validate_numericality_of(:due).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:interval) }
    it { should validate_numericality_of(:interval).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:ease) }
    it { should validate_numericality_of(:ease).is_greater_than_or_equal_to(1300) }
    it { should validate_presence_of(:lapses) }
    it { should validate_numericality_of(:lapses).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:reps) }
    it { should validate_numericality_of(:reps).is_greater_than_or_equal_to(0) }
    it { should validate_inclusion_of(:flag).in_range(0..7) }
    it { should validate_presence_of(:state) }
  end

  describe "scopes" do
    let(:user) { create(:user) }
    let(:deck) { create(:deck, user: user) }
    let(:note_type) { create(:note_type, user: user) }

    describe ".active" do
      it "excludes suspended and buried cards" do
        note = create(:note, user: user, note_type: note_type)
        # Delete auto-generated cards
        note.cards.destroy_all
        active = create(:card, note: note, deck: deck)
        _suspended = create(:card, :suspended, note: note, deck: deck)
        _buried = create(:card, :buried, note: note, deck: deck)
        expect(deck.cards.active).to contain_exactly(active)
      end
    end

    describe ".new_cards" do
      it "returns only new state cards" do
        note = create(:note, user: user, note_type: note_type)
        note.cards.destroy_all
        new_card = create(:card, note: note, deck: deck, state: :new)
        _review_card = create(:card, :review, note: note, deck: deck)
        expect(deck.cards.new_cards).to contain_exactly(new_card)
      end
    end
  end

  describe "#leech?" do
    it "returns true when lapses >= threshold" do
      card = build(:card, lapses: 8)
      expect(card.leech?).to be true
    end

    it "returns false when lapses < threshold" do
      card = build(:card, lapses: 7)
      expect(card.leech?).to be false
    end

    it "accepts custom threshold" do
      card = build(:card, lapses: 3)
      expect(card.leech?(3)).to be true
    end
  end

  describe "custom validations" do
    it "rejects home_deck same as deck" do
      deck = create(:deck)
      card = build(:card, deck: deck, home_deck: deck)
      expect(card).not_to be_valid
      expect(card.errors[:home_deck_id]).to be_present
    end
  end
end
