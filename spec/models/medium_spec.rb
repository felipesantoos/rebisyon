# frozen_string_literal: true

require "rails_helper"

RSpec.describe Medium, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:note_media).with_foreign_key(:media_id).dependent(:destroy) }
    it { should have_many(:notes).through(:note_media) }
  end

  describe "validations" do
    subject { build(:medium) }

    it { should validate_presence_of(:filename) }
    it { should validate_length_of(:filename).is_at_most(255) }
    it { should validate_presence_of(:size) }
    it { should validate_numericality_of(:size).is_greater_than(0) }
    it { should validate_presence_of(:mime_type) }
    it { should validate_length_of(:mime_type).is_at_most(100) }
    it { should validate_presence_of(:storage_path) }
    it { should validate_length_of(:storage_path).is_at_most(512) }

    it "validates hash presence" do
      medium = build(:medium)
      medium.hash_value = nil
      expect(medium).not_to be_valid
      expect(medium.errors[:hash]).to be_present
    end

    it "validates hash length" do
      medium = build(:medium)
      medium.hash_value = "abc"
      expect(medium).not_to be_valid
      expect(medium.errors[:hash]).to be_present
    end
  end

  describe "soft delete" do
    let!(:medium) { create(:medium) }

    it "supports soft delete" do
      medium.soft_delete!
      expect(medium.deleted?).to be true
      expect(Medium.where(id: medium.id)).to be_empty
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }

    describe ".images" do
      it "returns only image media" do
        img = create(:medium, user: user, mime_type: "image/jpeg")
        _aud = create(:medium, :audio, user: user)
        expect(Medium.images).to contain_exactly(img)
      end
    end
  end

  describe "#image?" do
    it "returns true for image mime type" do
      medium = build(:medium, mime_type: "image/png")
      expect(medium.image?).to be true
    end
  end

  describe "#audio?" do
    it "returns true for audio mime type" do
      medium = build(:medium, mime_type: "audio/mpeg")
      expect(medium.audio?).to be true
    end
  end

  describe "#video?" do
    it "returns true for video mime type" do
      medium = build(:medium, mime_type: "video/mp4")
      expect(medium.video?).to be true
    end
  end

  describe "#extension" do
    it "returns file extension" do
      medium = build(:medium, filename: "test.jpg")
      expect(medium.extension).to eq("jpg")
    end

    it "returns nil for extensionless filename" do
      medium = build(:medium, filename: "noext")
      expect(medium.extension).to be_nil
    end
  end

  describe "#used?" do
    it "returns false when no note_media" do
      medium = create(:medium)
      expect(medium.used?).to be false
    end
  end

  describe "#hash_value" do
    it "reads and writes the hash attribute" do
      medium = build(:medium)
      medium.hash_value = "a" * 64
      expect(medium.hash_value).to eq("a" * 64)
    end
  end
end
