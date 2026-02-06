# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profile, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { build(:profile) }

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }

    describe "name uniqueness" do
      it "rejects duplicate name for same user" do
        user = create(:user)
        create(:profile, user: user, name: "Default")
        duplicate = build(:profile, user: user, name: "Default")
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:name]).to be_present
      end

      it "allows same name for different users" do
        create(:profile, name: "Default")
        other = build(:profile, name: "Default")
        expect(other).to be_valid
      end

      it "allows reuse of name from soft-deleted profile" do
        user = create(:user)
        profile = create(:profile, user: user, name: "Default")
        profile.soft_delete!
        new_profile = build(:profile, user: user, name: "Default")
        expect(new_profile).to be_valid
      end
    end
  end

  describe "soft delete" do
    let(:user) { create(:user) }
    let!(:profile) { create(:profile, user: user) }

    it "supports soft delete" do
      profile.soft_delete!
      expect(profile.soft_deleted?).to be true
      expect(Profile.where(id: profile.id)).to be_empty
    end

    it "can be restored" do
      profile.soft_delete!
      profile.restore!
      expect(profile.soft_deleted?).to be false
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }

    describe ".ordered" do
      it "orders by name" do
        z = create(:profile, user: user, name: "Zebra")
        a = create(:profile, user: user, name: "Alpha")
        expect(user.profiles.ordered).to eq([a, z])
      end
    end

    describe ".ankiweb_enabled" do
      it "returns only ankiweb-enabled profiles" do
        _regular = create(:profile, user: user)
        ankiweb = create(:profile, :with_ankiweb, user: user)
        expect(user.profiles.ankiweb_enabled).to contain_exactly(ankiweb)
      end
    end

    describe ".for_user" do
      it "returns profiles for specified user" do
        profile = create(:profile, user: user)
        _other = create(:profile)
        expect(Profile.for_user(user)).to contain_exactly(profile)
      end
    end
  end
end
