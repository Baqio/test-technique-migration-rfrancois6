class Importer::CavegestCustomerFile
  Row = Struct.new(:line_number, :values, keyword_init: true)

  COLUMNS = %i[
  reference
  last_name
  first_name
  company_name
  address1
  zip
  city
  country_code
  email
  phone
  mobile

  shipping_last_name
  shipping_first_name
  shipping_company_name
  shipping_address1
  shipping_zip
  shipping_city
  shipping_country_code
  shipping_phone

  family_code
  family_label
  price_grid_code
  price_grid_label
  vat_number
  excise_number
  creation_date
  unusable
].freeze

  def initialize(path)
    @path = path
  end

  def rows
    parse!
    @rows_data
  end

  def announced_total
    parse!
    @total_announced
  end

  private

  def parse!
    return if @parsed
    
    @rows_data = []
    @total_announced = nil

    (2..roo_xlsx.last_row).each do |line_number|
      row = roo_xlsx.row(line_number)
      if row.all?(&:blank?) 
        next
      elsif row[0] == "TOTAL"
        @total_announced = row[3].to_i
      else
        @rows_data << Row.new(line_number: line_number, values: COLUMNS.zip(row).to_h)
      end
    end

    @parsed = true
  end

  def roo_xlsx
    @roo_xlsx ||= Roo::Excelx.new(@path).sheet(0)
  end
end