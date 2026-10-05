class ProductPrice::Import::Cavegest < Importer::Base
  def call
    file.rows.each do |row|
      import_row(row)
    end
    report
  end

  private

  def duplicate_references
    @duplicate_references ||= file.rows.map { |row| row.values["Ref"] }.tally.select { |key, value| value > 1 }.keys
  end

  def file
    @file ||= Importer::CavegestTariffFile.new(path)
  end

  def import_row(row)
    if duplicate_references.include?(row.values["Ref"])
      return trace(
        row,
        status: "rejected",
        source_key: row.values["Ref"],
        issues: [
          Importer::Issue.new(
            field:     :reference,
            message:   "référence utilisée par plusieurs produits différents dans le fichier",
            raw_value: row.values["Ref"]
          )
        ],
      )
    end

    result = ProductPrice::Import::CavegestMapper.new(row.values).call

    return trace(row, status: "rejected", source_key: row.values["Ref"], issues: result.errors ) if result.errors.any?

    ActiveRecord::Base.transaction(requires_new: true) do
      product = Product.find_or_initialize_by(reference: result.product_attributes[:reference])
      status  = product.new_record? ? "created" : "updated"
      product.assign_attributes(result.product_attributes)

      if product.save
        result.prices.each do |price|
          product_price = ProductPrice.find_or_initialize_by(product: product, grid_code: price[:grid_code])
          product_price.assign_attributes(price)
          product_price.save!
        end

        trace(row, status: status, source_key: row.values["Ref"], issues: result.warnings, record: product)
      else
        trace(row, status: "rejected", source_key: row.values["Ref"], issues: model_issues(product))
      end
    end

  end
end
