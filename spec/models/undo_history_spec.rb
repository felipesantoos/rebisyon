# frozen_string_literal: true

require "rails_helper"

RSpec.describe UndoHistory, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { build(:undo_history) }

    it { should validate_presence_of(:operation_type) }
    it { should validate_inclusion_of(:operation_type).in_array(UndoHistory::OPERATION_TYPES) }
    it { should validate_presence_of(:operation_data) }
  end

  describe "table name" do
    it "uses undo_history table" do
      expect(UndoHistory.table_name).to eq("undo_history")
    end
  end

  describe "constants" do
    it "defines OPERATION_TYPES" do
      expect(UndoHistory::OPERATION_TYPES).to eq(
        %w[edit_note delete_note move_card change_flag add_tag remove_tag change_deck]
      )
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }

    describe ".recent" do
      it "orders by created_at desc" do
        old = create(:undo_history, user: user)
        recent = create(:undo_history, user: user)
        expect(user.undo_histories.recent).to eq([recent, old])
      end
    end

    describe ".for_user" do
      it "returns undo histories for specified user" do
        history = create(:undo_history, user: user)
        _other = create(:undo_history)
        expect(UndoHistory.for_user(user)).to contain_exactly(history)
      end
    end
  end

  describe "#summary" do
    it "returns summary from operation_data" do
      history = build(:undo_history, operation_data: { "summary" => "Custom summary" })
      expect(history.summary).to eq("Custom summary")
    end

    it "returns titleized operation_type when no summary in data" do
      history = build(:undo_history, operation_data: { "details" => "some details" })
      expect(history.summary).to eq("Edit Note operation")
    end

    it "handles nil operation_data" do
      history = build_stubbed(:undo_history)
      allow(history).to receive(:operation_data).and_return(nil)
      expect(history.summary).to eq("Edit Note operation")
    end
  end

  describe "#details" do
    it "returns details from operation_data" do
      history = build(:undo_history, operation_data: { "details" => "Changed front field" })
      expect(history.details).to eq("Changed front field")
    end

    it "returns empty string when no details in data" do
      history = build(:undo_history, operation_data: { "summary" => "Edited" })
      expect(history.details).to eq("")
    end

    it "handles nil operation_data" do
      history = build_stubbed(:undo_history)
      allow(history).to receive(:operation_data).and_return(nil)
      expect(history.details).to eq("")
    end
  end
end
