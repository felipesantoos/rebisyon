# frozen_string_literal: true

require "rails_helper"

RSpec.describe SavedSearch, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { build(:saved_search) }

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }
    it { should validate_presence_of(:search_query) }
  end

  describe "soft delete" do
    let(:user) { create(:user) }
    let!(:search) { create(:saved_search, user: user) }

    it "supports soft delete" do
      search.soft_delete!
      expect(search.soft_deleted?).to be true
      expect(SavedSearch.where(id: search.id)).to be_empty
    end

    it "can be restored" do
      search.soft_delete!
      search.restore!
      expect(search.soft_deleted?).to be false
    end
  end

  describe "scopes" do
    describe ".ordered" do
      let(:user) { create(:user) }

      it "orders by name" do
        z = create(:saved_search, user: user, name: "Zebra")
        a = create(:saved_search, user: user, name: "Alpha")
        expect(user.saved_searches.ordered).to eq([a, z])
      end
    end
  end
end
