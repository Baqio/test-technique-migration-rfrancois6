class ProductPrice::Import::CavegestMapper
  N = Importer::Normalization

  Result = Struct.new(:product_attributes, :prices, :errors, :warnings, keyword_init: true)

  GRID_CODES = %w[DEPC CHR EXPO PART SALON].freeze

  VINTAGE_SUFFIX = /\s(\d{4}|N\.M\.)\z/

  def initialize(values)
    @values = values
  end

  def call
    @errors   = []
    @warnings = []

    if @values["Ref"].blank?
      @errors << Importer::Issue.new(
        field:     :reference,
        message:   "référence produit manquante",
        raw_value: @values["Ref"]
      )
    end

    Result.new(product_attributes: product_attributes, prices: prices, errors: @errors, warnings: @warnings)
  end

  private 

  def product_attributes
    {
      reference: @values["Ref"],
      name: name,
      vintage: vintage,
      color: color,
      volume_ml: volume,
      vat_rate: N.decimal(@values["TVA"]),
      stock: N.decimal(@values["Stock"])&.to_i
    }
  end
  
  def prices
    GRID_CODES.filter_map do |code|
      amount = N.decimal(@values[code])
      next if amount.blank?

      ht = amount_ht(code, amount)
      next if ht.blank?

      { grid_code: code, amount_ht: ht }
    end
  end

  def name
    name_and_vintage[0]
  end

  def vintage
    name_and_vintage[1]
  end

  def volume
    contenant = @values["Contenant"]
    return nil if contenant.blank?

    volume = contenant.match(/- (\d+\.\d+)/)
    unless volume 
      @warnings << Importer::Issue.new(
        field:      :volume,
        message:    "conditionnement donné à la place du contenant, volume non déterminé",
        raw_value:  @values["Contenant"]
      )
      return nil
    end

    (volume[1].to_f * 10).round
  end

  def amount_ht(code, amount)
    return amount unless code == "EXPO"

    tva = N.decimal(@values["TVA"])

    if tva.blank?
      @errors << Importer::Issue.new(
        field:     :vat_rate,
        message:   "taux de TVA manquant",
        raw_value: @values["TVA"]
      )
      return nil
    end
    (amount / (1 + tva / 100)).round(2)
  end
  
  def color
    return nil if @values["Couleur"].blank?
    @values["Couleur"].strip.capitalize
  end

  def name_and_vintage
    @name_and_vintage ||= begin
      designation = @values["Désignation"].to_s.strip

      [
        designation.sub(VINTAGE_SUFFIX, "").presence,
        designation.match(VINTAGE_SUFFIX)&.[](1)
      ]
    end
  end
end