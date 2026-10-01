require "spec_helper"

RSpec.describe Customer::Import::Cavegest do
  before { described_class.new(data_path("export_clients_cavegest.xlsx")).call }

  it "keeps the leading zero of postal codes" do
    expect(Customer.find_by(reference: "T00022").zip).to eq("01000")
  end

  it "skips the totals row at the bottom of the file" do
    expect(Customer.where(reference: "TOTAL")).to be_empty
  end

  it "stores the shipping address when it differs from the billing one" do
    customer = Customer.find_by(reference: "T00013")

    expect(customer.zip).to eq("04000")
    expect(customer.shipping_zip).to eq("11100")
  end

  it "imports every customer, merging exact duplicates" do
    expect(Customer.count).to eq(4994)
  end

  it "deactivates customers flagged as unusable in the source" do
    expect(Customer.where(active: false).count).to eq(340)
  end

  it "imports the billing address, not the shipping one" do
    customer = Customer.find_by(reference: "T00001")

    expect(customer).to have_attributes(
      last_name:    "MERCIER",
      first_name:   "Marc",
      company_name: "LE VERRE GALANT",
      city:         "Lyon",
      zip:          "69002",
      country_code: "FR"
    )
  end

  it "preserves the leading zero in phone numbers" do
    customer = Customer.find_by(reference: "T00002")

    expect(customer.phone).to eq("0222415817")
  end

  it "pads French postal codes to five characters" do
    short_zips = Customer.where(country_code: "FR").where("LENGTH(zip) < 5")

    expect(short_zips).to be_empty
  end
end
