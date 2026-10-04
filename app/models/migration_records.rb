class MigrationRecord < ActiveRecord::Base
  STATUSES = {
    created:  "created",
    updated:  "updated",
    rejected: "rejected",
  }.freeze
end