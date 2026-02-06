# frozen_string_literal: true

require "rails_helper"

RSpec.describe FlagName, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { build(:flag_name) }

    it { should validate_presence_of(:flag_number) }
    it { should validate_inclusion_of(:flag_number).in_range(1..7) }
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(50) }
    it { should validate_uniqueness_of(:flag_number).scoped_to(:user_id) }
  end

  describe "scopes" do
    describe ".for_flag" do
      let(:user) { create(:user) }

      it "filters by flag number" do
        flag1 = create(:flag_name, user: user, flag_number: 1, name: "Important")
        _flag2 = create(:flag_name, user: user, flag_number: 2, name: "Review")
        expect(FlagName.for_flag(1)).to contain_exactly(flag1)
      end
    end
  end
end
