# frozen_string_literal: true

require "rails_helper"

RSpec.describe NoteType, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:notes).dependent(:restrict_with_error) }
  end

  describe "validations" do
    subject { build(:note_type) }

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }
    it { should validate_presence_of(:fields_json) }
    it { should validate_presence_of(:card_types_json) }
    it { should validate_presence_of(:templates_json) }
  end

  describe "soft delete" do
    let(:user) { create(:user) }
    let!(:note_type) { create(:note_type, user: user, name: "Custom Type") }

    it "supports soft delete" do
      note_type.soft_delete!
      expect(note_type.soft_deleted?).to be true
      expect(NoteType.where(id: note_type.id)).to be_empty
    end
  end

  describe "#fields" do
    it "returns fields_json as array" do
      nt = build(:note_type, fields_json: [{ "name" => "Front" }])
      expect(nt.fields).to eq([{ "name" => "Front" }])
    end

    it "returns empty array if fields_json is not array" do
      nt = build(:note_type)
      nt.fields_json = "invalid"
      expect(nt.fields).to eq([])
    end
  end

  describe "#field_names" do
    it "returns array of field names" do
      nt = build(:note_type)
      expect(nt.field_names).to eq(%w[Front Back])
    end
  end

  describe "#card_type_names" do
    it "returns array of card type names" do
      nt = build(:note_type)
      expect(nt.card_type_names).to eq(["Forward"])
    end
  end

  describe "#templates" do
    it "returns templates_json as hash" do
      nt = build(:note_type)
      expect(nt.templates).to be_a(Hash)
      expect(nt.templates).to have_key("Front")
    end
  end

  describe "scopes" do
    describe ".ordered" do
      let(:user) { create(:user) }

      it "orders by name" do
        z = create(:note_type, user: user, name: "Zebra")
        a = create(:note_type, user: user, name: "Alpha")
        ordered = user.note_types.ordered.to_a
        expect(ordered.index(a)).to be < ordered.index(z)
      end
    end
  end
end
