# frozen_string_literal: true

require "rails_helper"

RSpec.describe Deck, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:parent).class_name("Deck").optional }
    it { should have_many(:children).class_name("Deck").with_foreign_key("parent_id").dependent(:destroy) }
    it { should have_many(:cards).dependent(:restrict_with_error) }
  end

  describe "validations" do
    subject { build(:deck) }

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }
  end

  describe "scopes" do
    let(:user) { create(:user) }

    describe ".roots" do
      it "returns only root decks" do
        root = create(:deck, user: user, name: "Custom Root")
        child = create(:deck, user: user, name: "Child", parent: root)
        expect(user.decks.roots).to include(root)
        expect(user.decks.roots).not_to include(child)
      end
    end

    describe ".ordered" do
      it "orders by name" do
        z_deck = create(:deck, user: user, name: "Zebra")
        a_deck = create(:deck, user: user, name: "Alpha")
        ordered = user.decks.ordered.to_a
        z_index = ordered.index(z_deck)
        a_index = ordered.index(a_deck)
        expect(a_index).to be < z_index
      end
    end
  end

  describe "soft delete" do
    let(:user) { create(:user) }
    let!(:deck) { create(:deck, user: user, name: "To Delete") }

    it "supports soft delete" do
      deck.soft_delete!
      expect(deck.deleted?).to be true
      expect(Deck.where(id: deck.id)).to be_empty
    end

    it "can be restored" do
      deck.soft_delete!
      deck.restore!
      expect(deck.deleted?).to be false
    end
  end

  describe "#full_name" do
    let(:user) { create(:user) }

    it "returns name for root deck" do
      deck = create(:deck, user: user, name: "Root")
      expect(deck.full_name).to eq("Root")
    end

    it "returns hierarchical name" do
      parent = create(:deck, user: user, name: "Parent")
      child = create(:deck, user: user, name: "Child", parent: parent)
      expect(child.full_name).to eq("Parent::Child")
    end
  end

  describe "#root?" do
    it "returns true for deck without parent" do
      deck = build(:deck, parent: nil)
      expect(deck.root?).to be true
    end
  end

  describe "#ancestors" do
    let(:user) { create(:user) }

    it "returns empty array for root deck" do
      deck = create(:deck, user: user, name: "Standalone")
      expect(deck.ancestors).to be_empty
    end

    it "returns parent chain" do
      grandparent = create(:deck, user: user, name: "GP")
      parent = create(:deck, user: user, name: "P", parent: grandparent)
      child = create(:deck, user: user, name: "C", parent: parent)
      expect(child.ancestors).to eq([parent, grandparent])
    end
  end

  describe "#descendant_ids" do
    let(:user) { create(:user) }

    it "returns all descendant IDs" do
      parent = create(:deck, user: user, name: "Par")
      child = create(:deck, user: user, name: "Chi", parent: parent)
      grandchild = create(:deck, user: user, name: "GC", parent: child)
      expect(parent.descendant_ids).to contain_exactly(child.id, grandchild.id)
    end
  end
end
