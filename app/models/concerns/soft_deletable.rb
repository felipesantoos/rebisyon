# frozen_string_literal: true

# Provides soft delete functionality using a deleted_at timestamp column.
#
# When included, adds:
# - default_scope that excludes soft-deleted records
# - soft_delete! method to mark record as deleted
# - restore! method to undelete a record
# - with_deleted scope to include deleted records
# - only_deleted scope to only show deleted records
# - deleted? predicate method
#
# @example
#   class Note < ApplicationRecord
#     include SoftDeletable
#   end
#
#   note.soft_delete!  # Sets deleted_at to current time
#   note.deleted?      # => true
#   note.restore!      # Clears deleted_at
#   Note.with_deleted  # Returns all records including deleted
#   Note.only_deleted  # Returns only deleted records
module SoftDeletable
  extend ActiveSupport::Concern

  included do
    # Default scope excludes soft-deleted records
    # NOTE: default_scope is generally discouraged by Rails community as it can lead to
    # unexpected query behavior. However, for soft deletes, it provides safety by
    # default. Consider using explicit scopes (e.g., .active, .not_deleted) throughout
    # the codebase if you prefer more explicit control.
    default_scope { where(deleted_at: nil) }

    # Scope to include deleted records
    scope :with_deleted, -> { unscope(where: :deleted_at) }

    # Scope to only show deleted records
    scope :only_deleted, -> { unscope(where: :deleted_at).where.not(deleted_at: nil) }

    # Alternative explicit scope (if removing default_scope, use this instead)
    # scope :active, -> { where(deleted_at: nil) }
    # scope :not_deleted, -> { where(deleted_at: nil) }
  end

  # Soft deletes the record by setting deleted_at timestamp
  # @return [Boolean] true if update was successful
  def soft_delete!
    update_column(:deleted_at, Time.current)
  end

  # Restores a soft-deleted record
  # @return [Boolean] true if update was successful
  def restore!
    # Clear the deleted_at in-memory first so ActiveRecord doesn't think it's destroyed
    self.deleted_at = nil
    self.class.unscoped.where(id: id).update_all(deleted_at: nil)
    reload
  end

  # Checks if the record has been soft-deleted
  # @return [Boolean]
  def deleted?
    deleted_at.present?
  end

  # Alias for deleted? following Rails conventions
  def destroyed?
    deleted?
  end
end
