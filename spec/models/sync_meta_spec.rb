# frozen_string_literal: true

require "rails_helper"

RSpec.describe SyncMeta, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { build(:sync_meta) }

    it { should validate_presence_of(:client_id) }
    it { should validate_length_of(:client_id).is_at_most(255) }
    it { should validate_uniqueness_of(:client_id).scoped_to(:user_id) }
    it { should validate_presence_of(:last_sync_usn) }
    it { should validate_numericality_of(:last_sync_usn).is_greater_than_or_equal_to(0) }
  end

  describe "table name" do
    it "uses sync_meta table" do
      expect(SyncMeta.table_name).to eq("sync_meta")
    end
  end

  describe "scopes" do
    describe ".for_user" do
      let(:user) { create(:user) }

      it "returns sync metas for specified user" do
        meta = create(:sync_meta, user: user)
        _other = create(:sync_meta)
        expect(SyncMeta.for_user(user)).to contain_exactly(meta)
      end
    end
  end
end
