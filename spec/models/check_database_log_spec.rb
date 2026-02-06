# frozen_string_literal: true

require "rails_helper"

RSpec.describe CheckDatabaseLog, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { build(:check_database_log) }

    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(CheckDatabaseLog::STATUSES) }
    it { should validate_presence_of(:issues_found) }
    it { should validate_numericality_of(:issues_found).is_greater_than_or_equal_to(0) }
  end

  describe "table name" do
    it "uses check_database_log table" do
      expect(CheckDatabaseLog.table_name).to eq("check_database_log")
    end
  end

  describe "constants" do
    it "defines STATUSES" do
      expect(CheckDatabaseLog::STATUSES).to eq(%w[running completed failed corrupted])
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }

    describe ".recent" do
      it "orders by created_at desc" do
        old = create(:check_database_log, user: user)
        recent = create(:check_database_log, user: user)
        expect(user.check_database_logs.recent).to eq([recent, old])
      end
    end

    describe ".with_issues" do
      it "returns only logs with issues" do
        _clean = create(:check_database_log, user: user)
        with_issues = create(:check_database_log, :with_issues, user: user)
        expect(user.check_database_logs.with_issues).to contain_exactly(with_issues)
      end
    end

    describe ".for_user" do
      it "returns logs for specified user" do
        log = create(:check_database_log, user: user)
        _other = create(:check_database_log)
        expect(CheckDatabaseLog.for_user(user)).to contain_exactly(log)
      end
    end
  end
end
