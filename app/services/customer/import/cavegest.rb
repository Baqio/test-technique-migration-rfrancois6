class Customer::Import::Cavegest < Importer::Base
  def call
    file.rows.each do |row|
      import_row(row)
    end
    report
  end

  private

  def file
    @file ||= Importer::CavegestCustomerFile.new(path)
  end

  def import_row(row)
    result = Customer::Import::CavegestMapper.new(row.values).call

    return trace(row, status: "rejected", source_key: row.values[:reference], issues: result.errors) if result.errors.any?

    ActiveRecord::Base.transaction(requires_new: true) do
      customer = Customer.find_or_initialize_by(reference: result.attributes[:reference])
      status   = customer.new_record? ? "created" : "updated"
      customer.assign_attributes(result.attributes)

      if customer.save
        trace(row, status: status, source_key: row.values[:reference], issues: result.warnings, record: customer)
      else
        trace(row, status: "rejected", source_key: row.values[:reference], issues: model_issues(customer))
      end
    end
  end
end