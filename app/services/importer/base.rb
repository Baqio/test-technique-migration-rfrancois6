class Importer::Base
  attr_reader :path, :report

  def initialize(path, report: MigrationReport.new)
    @path   = path
    @report = report
  end

  def call
    raise NotImplementedError
  end

  private

  def source
    File.basename(path)
  end

  def trace(row, status:, source_key:, issues: [], record: nil)
    reason    = issues.map(&:message).join(" ; ").presence
    raw_value = issues.map(&:raw_value).compact.join(" ; ").presence

    MigrationRecord.create!(
      source_file: source,
      source_line: row.line_number,
      source_key:  source_key,
      status:      status,
      reason:      reason,
      raw_value:   raw_value,
      record_type: record&.class&.name,
      record_id:   record&.id
    )

    report.count(status)

    if status == "rejected"
      report.error(source: source, locator: row.line_number, message: reason)
    elsif reason
      report.warn(source: source, locator: row.line_number, message: reason)
    end
  end

  def model_issues(record)
    record.errors.map do |error|
      Importer::Issue.new(
        field:     error.attribute,
        message:   error.full_message,
        raw_value: nil
      )
    end
  end
end
