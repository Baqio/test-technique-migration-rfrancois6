class MigrationRecord < ActiveRecord::Base
  STATUSES = {
    created:  "created",
    updated:  "updated",
    rejected: "rejected",
    warning:  "imported_with_warning"
  }.freeze
end