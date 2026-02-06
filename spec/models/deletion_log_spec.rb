# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeletionLog, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { build(:deletion_log) }

    it { should validate_presence_of(:object_type) }
    it { should validate_inclusion_of(:object_type).in_array(%w[note card deck note_type]) }
    it { should validate_presence_of(:object_id) }
    it { should validate_presence_of(:deleted_at) }
  end

  describe "table name" do
    it "uses deletions_log table" do
      expect(DeletionLog.table_name).to eq("deletions_log")
    end
  end
end
