# frozen_string_literal: true

class SyncMeta < ApplicationRecord
  self.table_name = "sync_meta"

  include UserScoped

  validates :client_id, presence: true, length: { maximum: 255 }
  validates :client_id, uniqueness: { scope: :user_id }
  validates :last_sync_usn, presence: true,
            numericality: { greater_than_or_equal_to: 0 }
end
