# frozen_string_literal: true

require "rails_helper"

RSpec.describe Backup, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { build(:backup) }

    it { should validate_presence_of(:filename) }
    it { should validate_length_of(:filename).is_at_most(255) }
    it { should validate_presence_of(:size) }
    it { should validate_numericality_of(:size).is_greater_than(0) }
    it { should validate_presence_of(:storage_path) }
    it { should validate_length_of(:storage_path).is_at_most(512) }
    it { should validate_presence_of(:backup_type) }
    it { should validate_inclusion_of(:backup_type).in_array(%w[automatic manual pre_operation]) }
  end

  describe "scopes" do
    let(:user) { create(:user) }

    describe ".automatic" do
      it "returns only automatic backups" do
        auto = create(:backup, user: user)
        _manual = create(:backup, :manual, user: user)
        expect(user.backups.automatic).to contain_exactly(auto)
      end
    end

    describe ".manual" do
      it "returns only manual backups" do
        _auto = create(:backup, user: user)
        manual = create(:backup, :manual, user: user)
        expect(user.backups.manual).to contain_exactly(manual)
      end
    end

    describe ".recent" do
      it "orders by created_at desc" do
        old = create(:backup, user: user)
        recent = create(:backup, user: user)
        expect(user.backups.recent).to eq([recent, old])
      end
    end

    describe ".for_user" do
      it "returns backups for specified user" do
        backup = create(:backup, user: user)
        _other = create(:backup)
        expect(Backup.for_user(user)).to contain_exactly(backup)
      end
    end
  end
end
