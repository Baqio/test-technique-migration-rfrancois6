class Customer::Import::CavegestMapper
  N = Importer::Normalization

  Result = Struct.new(:attributes, :errors, :warnings, keyword_init: true)

  KINDS = {
    "C" => "customer",
    "P" => "prospect",
    "F" => "supplier",
    "R" => "customer"
  }.freeze

  def initialize(values)
    @values = values
  end

  def call
    @errors   = []
    @warnings = []

    check_identity

    Result.new(attributes: attributes, errors: @errors, warnings: @warnings)
  end

  private

  def attributes
    {
      reference:         @values[:reference],
      company_name:      @values[:company_name],
      first_name:        @values[:first_name],
      last_name:         @values[:last_name],
      address1:          @values[:address1],
      city:              @values[:city],
      zip:               N.zip(@values[:zip], country),
      country_code:      country,
      phone:             N.phone(@values[:phone]),
      mobile:            N.phone(@values[:mobile]),
      email:             email,
      kind:              kind,
      customer_category: @values[:family_label],
      price_grid_code:   @values[:price_grid_code],
      vat_number:        vat_number,
      excise_number:     @values[:excise_number],
      creation_date:     creation_date,
      active:            active?,

      use_billing_address: shipping_values.empty?
    }.merge(shipping_attributes)
  end

  def country
    @country ||= N.country_code(@values[:country_code])
  end

  def email
    if @values[:email] == "contact@baqio.fake"
      @warnings << Importer::Issue.new(
        field:     :email,
        message:   "email de remplissage supprimé",
        raw_value: @values[:email]
      )
      return nil
    end
    @values[:email]
  end

  def kind
    code = @values[:family_code].to_s.strip

    if code == "R"
      @warnings << Importer::Issue.new(
        field:     :family_code,
        message:   "revendeur importé comme client",
        raw_value: @values[:family_code]
      )
    end

    unless KINDS.key?(code)
      @errors << Importer::Issue.new(
        field:     :family_code,
        message:   "code famille inconnu",
        raw_value: @values[:family_code]
      )
    end
    KINDS[code]
  end

  def vat_number
    return if @values[:vat_number].blank?
    @values[:vat_number].gsub(" ","")
  end

  def creation_date
    return if @values[:creation_date].blank?
    @values[:creation_date].to_date
  end

  SHIPPING_KEYS = %i[
    shipping_last_name
    shipping_first_name
    shipping_company_name
    shipping_address1
    shipping_zip
    shipping_city
    shipping_country_code
    shipping_phone
  ].freeze

  def shipping_values
    @shipping_values ||= @values.slice(*SHIPPING_KEYS).reject { |_key, value| value.blank? }
  end

  def shipping_attributes
    return {} if shipping_values.empty?

    shipping_country = N.country_code(@values[:shipping_country_code])

    {
      shipping_last_name:    @values[:shipping_last_name],
      shipping_first_name:   @values[:shipping_first_name],
      shipping_company_name: @values[:shipping_company_name],
      shipping_address1:     @values[:shipping_address1],
      shipping_city:         @values[:shipping_city],
      shipping_zip:          N.zip(@values[:shipping_zip], shipping_country),
      shipping_country_code: shipping_country,
      shipping_phone:        N.phone(@values[:shipping_phone])
    }
  end

  def check_identity
    return if @values.values_at(:company_name, :first_name, :last_name).any?(&:present?)

    @errors << Importer::Issue.new(
      field:   :company_name,
      message: "ni raison sociale, ni nom, ni prénom",
      raw_value: nil
    )
  end

  def active?
    @values[:unusable] != 1
  end
end