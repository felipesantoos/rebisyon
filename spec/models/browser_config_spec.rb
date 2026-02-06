# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrowserConfig, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
  end

  describe "validations" do
    subject { build(:browser_config) }

    it { should validate_presence_of(:visible_columns) }
    it { should validate_inclusion_of(:sort_direction).in_array(%w[asc desc]) }
  end

  describe "table name" do
    it "uses browser_config table" do
      expect(BrowserConfig.table_name).to eq("browser_config")
    end
  end

  describe "defaults" do
    it "has default visible columns" do
      config = BrowserConfig.new
      expect(config.visible_columns).to eq(%w[note deck tags due interval ease])
    end

    it "has default sort direction" do
      config = BrowserConfig.new
      expect(config.sort_direction).to eq("asc")
    end

    it "has default empty column widths" do
      config = BrowserConfig.new
      expect(config.column_widths).to eq({})
    end
  end
end
