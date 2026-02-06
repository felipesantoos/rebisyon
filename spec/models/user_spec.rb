# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_one(:user_preference).dependent(:destroy) }
    it { should have_many(:decks).dependent(:destroy) }
    it { should have_many(:note_types).dependent(:destroy) }
    it { should have_many(:notes).dependent(:destroy) }
    it { should have_many(:cards).through(:notes) }
  end

  describe "validations" do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should allow_value("user@example.com").for(:email) }
    it { should_not allow_value("invalid-email").for(:email) }
  end

  describe "soft delete" do
    let!(:user) { create(:user) }

    it "supports soft delete" do
      user.soft_delete!
      expect(user.soft_deleted?).to be true
      expect(user.deleted_at).to be_present
    end

    it "excludes soft-deleted users from default scope" do
      user.soft_delete!
      expect(User.where(id: user.id)).to be_empty
    end

    it "includes soft-deleted users with with_deleted scope" do
      user.soft_delete!
      expect(User.with_deleted.where(id: user.id)).to exist
    end

    it "can restore soft-deleted users" do
      user.soft_delete!
      user.restore!
      expect(user.soft_deleted?).to be false
      expect(User.where(id: user.id)).to exist
    end
  end

  describe "#track_login!" do
    let(:user) { create(:user) }

    it "updates last_login_at timestamp" do
      expect { user.track_login! }.to change { user.reload.last_login_at }
    end
  end

  describe "#preference" do
    let(:user) { create(:user) }

    it "returns user preference" do
      # setup_defaults creates a preference, so it should already exist
      expect(user.preference).to be_a(UserPreference)
    end
  end

  describe "callbacks" do
    it "sets up defaults after create" do
      user = create(:user)
      expect(user.user_preference).to be_present
    end
  end
end
