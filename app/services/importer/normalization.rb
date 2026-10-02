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
  
  COUNTRY_CODES = {
  "FR"        => "FR",
  "FRANCE"    => "FR",
  "BE"        => "BE",
  "BELGIQUE"  => "BE",
  "DE"        => "DE",
  "ALLEMAGNE" => "DE"
  }.freeze

  def country_code(value)
    return nil if value.blank?

    COUNTRY_CODES[value.to_s.strip.upcase]
  end

  def decimal(value)
    return nil if value.blank?
    cleaned = value.to_s.gsub(/[^0-9,.-]/, "").gsub(",",".")
    return nil unless cleaned.match?(/\A-?\d+(\.\d+)?\z/)
    BigDecimal(cleaned)
  end

  def phone(value)
    return nil if value.blank?

    cleaned = value.to_s.strip
    return nil if cleaned.upcase == "N/C"

    cleaned.match?(/\A\d{9}\z/) ? "0#{cleaned}" : cleaned
  end
end
