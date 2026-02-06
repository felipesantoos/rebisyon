# frozen_string_literal: true

require "rails_helper"

RSpec.describe NoteMedium, type: :model do
  describe "associations" do
    it { should belong_to(:note) }
    it { should belong_to(:medium).with_foreign_key(:media_id) }
  end

  describe "validations" do
    it "validates field_name length" do
      note = create(:note)
      medium = create(:medium, user: note.user)
      nm = NoteMedium.new(note: note, media_id: medium.id, field_name: "a" * 101)
      expect(nm).not_to be_valid
    end
  end
end
