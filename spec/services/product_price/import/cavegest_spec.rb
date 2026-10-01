require "spec_helper"

RSpec.describe ProductPrice::Import::Cavegest do
  before { described_class.new(data_path("export_tarifs_cavegest.csv")).call }

  it "never stores a price at zero" do
    expect(ProductPrice.where(amount_ht: 0).count).to eq(0)
  end

  it "parses decimal prices written with a comma and a currency suffix" do
    product = Product.find_by(reference: "COT196")
    price   = ProductPrice.find_by(product: product, grid_code: "DEPC")

    expect(price.amount_ht).to eq(BigDecimal("19.31"))
  end

  it "reads the volume of half bottles" do
    product = Product.find_by(reference: "CUV234")

    expect(product.volume_ml).to eq(375)
  end

  it "leaves the volume empty when the source has no container" do
    expect(Product.where(volume_ml: 0).count).to eq(0)
  end

  it "converts EXPO prices to HT using the product VAT rate" do
    product    = Product.find_by(reference: "TRA231")
    expo_price = ProductPrice.find_by(product: product, grid_code: "EXPO")
    depc_price = ProductPrice.find_by(product: product, grid_code: "DEPC")

    expect(expo_price.amount_ht).to eq(depc_price.amount_ht)
  end
end
