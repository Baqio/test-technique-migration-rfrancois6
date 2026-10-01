module Importer::Normalization
  module_function

  def text(value)
    return nil if value.nil?

    value.to_s.strip
  end

  def zip(value, country_code = "FR")
    return nil if value.blank?

    cleaned = value.to_s.strip
    country_code == "FR" ? cleaned.rjust(5, "0") : cleaned
  end

  def country_code(value)
    value.to_s.strip[0, 2].upcase
  end

  def decimal(value)
    return nil if value.blank?
    cleaned = value.to_s.gsub(/[^0-9,.-]/, "").gsub(",",".")
    return nil unless cleaned.match?(/\A-?\d+(\.\d+)?\z/)
    BigDecimal(cleaned)
  end
end
