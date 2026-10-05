require "spec_helper"

RSpec.describe ProductPrice::Import::CavegestMapper do
  let(:base_values) do
    {
      "Ref"         => "COT196",
      "Désignation" => "Coteaux Nord 2019",
      "Contenant"   => "Bouteille - 75.0",
      "Couleur"     => "Rouge",
      "TVA"         => "20",
      "DEPC"        => "  19,31 EUR",
      "CHR"         => "16,99",
      "EXPO"        => "23,17",
      "PART"        => "22,79",
      "SALON"       => "",
      "Stock"       => "28"
    }
  end

  def map(overrides = {})
    described_class.new(base_values.merge(overrides)).call
  end

  def price_for(result, grid_code)
    result.prices.find { |price| price[:grid_code] == grid_code }
  end

  describe "#call" do
    it "splits the vintage out of the product name" do
      expect(map.product_attributes).to include(
        name:    "Coteaux Nord",
        vintage: "2019"
      )
    end

    it "keeps the N.M. mention as the vintage" do
      result = map("Désignation" => "Vieilles Vignes N.M.")

      expect(result.product_attributes).to include(
        name:    "Vieilles Vignes",
        vintage: "N.M."
      )
    end

    it "leaves the vintage empty when the name carries no year" do
      result = map("Désignation" => "La Pierre Blanche")

      expect(result.product_attributes[:name]).to eq("La Pierre Blanche")
      expect(result.product_attributes[:vintage]).to be_nil
    end

    it "normalises the colour case" do
      expect(map("Couleur" => "blanc").product_attributes[:color]).to eq("Blanc")
      expect(map("Couleur" => "BLANC").product_attributes[:color]).to eq("Blanc")
    end

    it "reads the volume from the container label" do
      expect(map.product_attributes[:volume_ml]).to eq(750)
      expect(map("Contenant" => "BIB - 300.0").product_attributes[:volume_ml]).to eq(3000)
    end

    it "reads the volume of half bottles" do
      result = map("Contenant" => "½ Bouteille - 37.5")

      expect(result.product_attributes[:volume_ml]).to eq(375)
    end

    it "leaves the volume empty when no container is given" do
      expect(map("Contenant" => "").product_attributes[:volume_ml]).to be_nil
    end

    it "leaves the volume empty for packaging labels and flags them" do
      result = map("Contenant" => "6 x 75")

      expect(result.product_attributes[:volume_ml]).to be_nil
      expect(result.warnings).not_to be_empty
    end

    it "reads the VAT rate written with a percent sign" do
      expect(map("TVA" => "20%").product_attributes[:vat_rate]).to eq(BigDecimal("20"))
    end

    it "reads the VAT rate written with a comma" do
      expect(map("TVA" => "5,50").product_attributes[:vat_rate]).to eq(BigDecimal("5.5"))
    end

    it "builds one price per grid filled in the source" do
      expect(map.prices.map { |price| price[:grid_code] }).to contain_exactly("DEPC", "CHR", "EXPO", "PART")
    end

    it "skips grids left empty in the source" do
      expect(map.prices.map { |price| price[:grid_code] }).not_to include("SALON")
    end

    it "parses prices written with a comma and a currency suffix" do
      expect(price_for(map, "DEPC")[:amount_ht]).to eq(BigDecimal("19.31"))
    end

    it "converts EXPO prices to HT using the product VAT rate" do
      result = map

      expect(price_for(result, "EXPO")[:amount_ht]).to eq(price_for(result, "DEPC")[:amount_ht])
    end

    it "converts EXPO prices with the reduced VAT rate" do
      result = map("TVA" => "5,50", "DEPC" => "11,66", "EXPO" => "12,30")

      expect(price_for(result, "EXPO")[:amount_ht]).to eq(BigDecimal("11.66"))
    end

    it "rejects the EXPO price when the VAT rate cannot be read" do
      result = map("TVA" => "")

      expect(price_for(result, "EXPO")).to be_nil
      expect(result.errors).not_to be_empty
    end

    it "rejects rows with no reference" do
      expect(map("Ref" => "").errors).not_to be_empty
    end
  end
end