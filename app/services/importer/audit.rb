class Importer::Audit
  CUSTOMER_FILE = File.join(DATA_DIR, "export_clients_cavegest.xlsx")
  TARIFF_FILE   = File.join(DATA_DIR, "export_tarifs_cavegest.csv")

  KNOWN_COUNTRIES = %w[FR BE DE].freeze

  Control = Struct.new(:label, :expected, :actual, :detail, keyword_init: true) do
    def ok?
      expected == actual
    end
  end

  def controls
    [
      Control.new(label: "Clients repris",
                  expected: expected_customers, actual: Customer.count),

      Control.new(label: "Produits repris",
                  expected: expected_products, actual: Product.count),

      Control.new(label: "Tarifs repris",
                  expected: expected_prices, actual: ProductPrice.count),

      Control.new(label: "Grilles tarifaires sans aucun prix",
                  expected: 0, actual: grids_without_prices.size, detail: grids_without_prices.join(", ")),

      Control.new(label: "Grilles tarifaires portées par aucun client",
                  expected: 0, actual: grids_without_customers.size, detail: grids_without_customers.join(", ")),

      Control.new(label: "Produits sans aucun tarif",
                  expected: 0, actual: Product.where.missing(:product_prices).count),

      Control.new(label: "Tarifs à zéro",
                  expected: 0, actual: ProductPrice.where(amount_ht: 0).count),

      Control.new(label: "Codes postaux français incomplets",
                  expected: 0,
                  actual: Customer.where(country_code: "FR").where("LENGTH(zip) < 5").count),

      Control.new(label: "Codes pays inconnus",
                  expected: 0,
                  actual: Customer.where.not(country_code: KNOWN_COUNTRIES).where.not(country_code: nil).count)
    ]
  end

  def figures
    {
      "Clients actifs"       => Customer.where(active: true).count,
      "Clients inactifs"     => Customer.where(active: false).count,
      "Clients par type"     => Customer.group(:kind).count,
      "Clients par grille"   => Customer.group(:price_grid_code).count,
      "Tarifs par grille"    => ProductPrice.group(:grid_code).count,
      "Lignes non reprises"  => MigrationRecord.where(status: "rejected").count,
      "Total annoncé par CaveGest" => customer_file.announced_total
    }
  end

  def to_s
    return "Aucune reprise n'a été effectuée sur cette base." if MigrationRecord.count.zero?

    ([header, controls_section, figures_section, footer]).join("\n\n")
  end

  private

  def customer_file
    @customer_file ||= Importer::CavegestCustomerFile.new(CUSTOMER_FILE)
  end

  def tariff_file
    @tariff_file ||= Importer::CavegestTariffFile.new(TARIFF_FILE)
  end

  def rejected(file)
    MigrationRecord.where(source_file: File.basename(file), status: "rejected").count
  end

  def expected_customers
    customer_file.rows.map { |row| row.values[:reference] }.uniq.size - rejected(CUSTOMER_FILE)
  end

  def expected_products
    tariff_file.rows.size - rejected(TARIFF_FILE)
  end

  def expected_prices
    kept = Product.pluck(:reference).to_set

    tariff_file.rows.sum do |row|
      next 0 unless kept.include?(row.values["Ref"])

      ProductPrice::Import::CavegestMapper::GRID_CODES.count { |code| row.values[code].present? }
    end
  end

  def grids_without_prices
    Customer.distinct.pluck(:price_grid_code).compact - ProductPrice.distinct.pluck(:grid_code)
  end

  def grids_without_customers
    ProductPrice.distinct.pluck(:grid_code) - Customer.distinct.pluck(:price_grid_code).compact
  end

  def header
    "AUDIT DE LA REPRISE CAVEGEST — #{Date.today.strftime('%d/%m/%Y')}"
  end

  def controls_section
    lines = controls.map do |control|
      line = "  #{(control.ok? ? 'OK' : 'ÉCART').ljust(5)}  #{control.label} : #{control.actual} (attendu #{control.expected})"
      line += " — #{control.detail}" if control.detail.present?
      line
    end

    (["CONTRÔLES"] + lines).join("\n")
  end

  def figures_section
    lines = figures.map { |label, value| "  #{label} : #{format_figure(value)}" }

    (["RÉPARTITION"] + lines).join("\n")
  end

  def format_figure(value)
    value.is_a?(Hash) ? value.map { |k, v| "#{k || 'non renseigné'} #{v}" }.join(", ") : value.to_s
  end

  def footer
    failing = controls.reject(&:ok?)

    return "Tous les contrôles sont conformes." if failing.empty?

    "#{failing.size} contrôle(s) en écart, à examiner avant mise en service."
  end
end