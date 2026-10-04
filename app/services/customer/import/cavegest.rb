class Customer::Import::Cavegest < Importer::Base
  def call
    Importer::CavegestCustomerFile.new(path).rows.each do |row|
      import_row(row)
    end

    report
  end

  private

  def import_row(row)
    result = Customer::Import::CavegestMapper.new(row.values).call

    return trace(row, status: "rejected", issues: result.errors) if result.errors.any?

    ActiveRecord::Base.transaction(requires_new: true) do
      customer = Customer.find_or_initialize_by(reference: result.attributes[:reference])
      status   = customer.new_record? ? "created" : "updated"
      customer.assign_attributes(result.attributes)

      if customer.save
        trace(row, status: status, issues: result.warnings, customer: customer)
      else
        trace(row, status: "rejected", issues: model_issues(customer))
      end
    end
  end

  def trace(row, status:, issues: [], customer: nil)
    reason    = issues.map(&:message).join(" ; ").presence
    raw_value = issues.map(&:raw_value).compact.join(" ; ").presence

    MigrationRecord.create!(
      source_file: source,
      source_line: row.line_number,
      source_key:  row.values[:reference],
      status:      status,
      reason:      reason,
      raw_value:   raw_value,
      record_type: customer&.class&.name,
      record_id:   customer&.id
    )

    report.count(status)

    if status == "rejected"
      report.error(source: source, locator: row.line_number, message: reason)
    elsif reason
      report.warn(source: source, locator: row.line_number, message: reason)
    end
  end

  def model_issues(customer)
    customer.errors.map do |error|
      Customer::Import::CavegestMapper::Issue.new(
        field:     error.attribute,
        message:   error.full_message,
        raw_value: nil
      )
    end
  end
end