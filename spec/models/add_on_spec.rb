# frozen_string_literal: true

require "rails_helper"

RSpec.describe AddOn, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { build(:add_on) }

    it { should validate_presence_of(:code) }
    it { should validate_length_of(:code).is_at_most(50) }
    it { should validate_uniqueness_of(:code).scoped_to(:user_id) }
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }
    it { should validate_presence_of(:version) }
    it { should validate_length_of(:version).is_at_most(20) }
  end

  describe "scopes" do
    let(:user) { create(:user) }

    describe ".enabled" do
      it "returns only enabled add-ons" do
        enabled = create(:add_on, user: user)
        _disabled = create(:add_on, :disabled, user: user)
        expect(user.add_ons.enabled).to contain_exactly(enabled)
      end
    end

    describe ".disabled" do
      it "returns only disabled add-ons" do
        _enabled = create(:add_on, user: user)
        disabled = create(:add_on, :disabled, user: user)
        expect(user.add_ons.disabled).to contain_exactly(disabled)
      end
    end

    describe ".for_user" do
      it "returns add-ons for specified user" do
        addon = create(:add_on, user: user)
        _other = create(:add_on)
        expect(AddOn.for_user(user)).to contain_exactly(addon)
      end
    end
  end
end
