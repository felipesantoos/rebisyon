# frozen_string_literal: true

require "rails_helper"

RSpec.describe JwtDenylist, type: :model do
  describe "table name" do
    it "uses jwt_denylist table" do
      expect(JwtDenylist.table_name).to eq("jwt_denylist")
    end
  end

  describe "revocation strategy" do
    it "includes Devise JWT Denylist strategy" do
      expect(JwtDenylist.ancestors).to include(Devise::JWT::RevocationStrategies::Denylist)
    end
  end
end
