# frozen_string_literal: true

require "rails_helper"

RSpec.describe Note, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:note_type) }
    it { should have_many(:cards).dependent(:destroy) }
    it { should have_many(:note_media).dependent(:destroy) }
    it { should have_many(:media).through(:note_media) }
  end

  describe "validations" do
    subject { build(:note) }

    it { should validate_presence_of(:fields_json) }
    it { should validate_presence_of(:tags) }
  end

  describe "guid" do
    it "generates a UUID on create" do
      note = build(:note, guid: nil)
      note.valid?
      expect(note.guid).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    end

    it "validates UUID format" do
      note = build(:note, guid: "invalid")
      expect(note).not_to be_valid
      expect(note.errors[:guid]).to be_present
    end
  end

  describe "soft delete" do
    let(:user) { create(:user) }
    let(:note_type) { create(:note_type, user: user) }
    let!(:note) { create(:note, user: user, note_type: note_type) }

    it "supports soft delete" do
      note.soft_delete!
      expect(note.deleted?).to be true
      expect(Note.where(id: note.id)).to be_empty
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }
    let(:note_type) { create(:note_type, user: user) }

    describe ".tagged" do
      it "filters by tag" do
        tagged = create(:note, user: user, note_type: note_type, tags: %w[vocab grammar])
        _other = create(:note, user: user, note_type: note_type, tags: ["other"])
        expect(Note.tagged("vocab")).to contain_exactly(tagged)
      end
    end

    describe ".marked" do
      it "returns only marked notes" do
        marked = create(:note, :marked, user: user, note_type: note_type)
        _unmarked = create(:note, user: user, note_type: note_type)
        expect(Note.marked).to contain_exactly(marked)
      end
    end
  end

  describe "#first_field" do
    it "returns the first field value" do
      note_type = build(:note_type)
      note = build(:note, note_type: note_type, fields_json: { "Front" => "Hello", "Back" => "World" })
      expect(note.first_field).to eq("Hello")
    end
  end
end
