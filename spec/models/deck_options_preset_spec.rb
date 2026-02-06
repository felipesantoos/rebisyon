# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeckOptionsPreset, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { build(:deck_options_preset) }

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }
  end

  describe "soft delete" do
    let(:user) { create(:user) }
    let!(:preset) { create(:deck_options_preset, user: user, name: "Custom Preset") }

    it "supports soft delete" do
      preset.soft_delete!
      expect(preset.deleted?).to be true
      expect(DeckOptionsPreset.where(id: preset.id)).to be_empty
    end

    it "can be restored" do
      preset.soft_delete!
      preset.restore!
      expect(preset.deleted?).to be false
    end
  end

  describe "scopes" do
    describe ".ordered" do
      let(:user) { create(:user) }

      it "orders by name" do
        z = create(:deck_options_preset, user: user, name: "Zebra")
        a = create(:deck_options_preset, user: user, name: "Alpha")
        ordered = user.deck_options_presets.ordered.to_a
        expect(ordered.index(a)).to be < ordered.index(z)
      end
    end
  end
end
