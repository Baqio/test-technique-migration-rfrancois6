require "spec_helper"

RSpec.describe Customer::Import::CavegestMapper do
  let(:base_values) do
  {
    reference:    "T00001",
    last_name:    "MERCIER",
    first_name:   "Marc",
    company_name: "LE VERRE GALANT",
    address1:     "12 rue des Vignes",
    zip:          69002,
    city:         "Lyon",
    country_code: "FRANCE",
    email:        "marc.mercier@example.fr",
    phone:        222415817,
    mobile:       nil,

    shipping_last_name:    nil,
    shipping_first_name:   nil,
    shipping_company_name: nil,
    shipping_address1:     nil,
    shipping_zip:          nil,
    shipping_city:         nil,
    shipping_country_code: nil,
    shipping_phone:        nil,

    family_code:      "C",
    family_label:     "CLIENT FRANCE",
    price_grid_code:  "DEPC",
    price_grid_label: "DEPOT CAVE",
    vat_number:       "FR 12 345678901",
    excise_number:    nil,
    creation_date:    Date.new(2011, 5, 14),
    unusable:         nil
  }
  end

  def map(overrides = {})
    described_class.new(base_values.merge(overrides)).call
  end

  describe "#call" do
    it "copies plain text fields unchanged" do
      expect(map.attributes).to include(
        reference:    "T00001",
        last_name:    "MERCIER",
        first_name:   "Marc",
        company_name: "LE VERRE GALANT"
      )
    end

    it "rejects rows with no company name, first name or last name" do
      result = map(company_name: nil, first_name: nil, last_name: nil)

      expect(result.errors).not_to be_empty
    end

    it "pads French postal codes to five characters" do
      expect(map(zip: 4000).attributes[:zip]).to eq("04000")
    end

    it "leaves five-digit postal codes unchanged" do
      expect(map.attributes[:zip]).to eq("69002")
    end

    it "restores the leading zero of phone numbers" do
      expect(map.attributes[:phone]).to eq("0222415817")
    end

    it "translates country names into ISO codes" do
      expect(map(country_code: "France   ").attributes[:country_code]).to eq("FR")
    end
    
    it "treats customers with no country as French" do
      expect(map(country_code: nil).attributes[:country_code]).to eq("FR")
      expect(map(country_code: "").attributes[:country_code]).to eq("FR")
    end

    it "treats unknown country as nil and raises a warning" do
      result = map(country_code: "Suisse")

      expect(result.attributes[:country_code]).to be_nil
      expect(result.warnings).not_to be_empty
    end

    it "accepts creation dates written as text" do
      expect(map(creation_date: "14/05/2011").attributes[:creation_date]).to eq(Date.new(2011, 5, 14))
      expect(map(creation_date: "03/05/2011").attributes[:creation_date]).to eq(Date.new(2011, 5, 3))
    end

    it "keeps real dates unchanged" do 
      creation_date = map.attributes[:creation_date]

      expect(creation_date).to eq(Date.new(2011, 5, 14))
      expect(creation_date).to be_a(Date)
    end

    it "strips the spaces inside VAT numbers" do
      expect(map.attributes[:vat_number]).to eq("FR12345678901")
    end

    it "maps the C family code to a customer" do
      expect(map(family_code: "C").attributes[:kind]).to eq("customer")
    end

    it "maps the P family code to a prospect" do
      expect(map(family_code: "P").attributes[:kind]).to eq("prospect")
    end

    it "maps the F family code to a supplier" do
      expect(map(family_code: "F").attributes[:kind]).to eq("supplier")
    end

    it "maps resellers to customers for review" do
      result = map(family_code: "R")

      expect(result.attributes[:kind]).to eq("customer")
    end

    it "rejects rows whose family code is unknown" do
      result = map(family_code: "X")

      expect(result.errors).not_to be_empty
    end

    it "normalises the family label whatever the case used in the source" do
      expect(map(family_label: "CLIENT FRANCE").attributes[:customer_category]).to eq("Client France")
    end

    it "reads the price grid code from the source" do
      expect(map.attributes[:price_grid_code]).to eq("DEPC")
    end

    it "marks rows flagged as unusable in the source as inactive" do
      expect(map(unusable: 1).attributes[:active]).to be(false)
    end

    it "marks every other row as active" do
      expect(map.attributes[:active]).to be(true)
    end

    it "treats a shipping address with no country as French" do
      result = map(shipping_address1: "4 quai du Port", shipping_zip: 4000, shipping_city: "Digne")

      expect(result.attributes).to include(
        shipping_country_code: "FR",
        shipping_zip:          "04000"
      )
    end

    it "falls back on the billing address when no shipping address is given" do
      result = map
      
      expect(result.attributes[:use_billing_address]).to be(true)
      expect(result.attributes[:shipping_city]).to be_nil
    end

    it "stores the shipping address when the source provides one" do
      result = map(
        shipping_address1: "4 quai du Port",
        shipping_zip:      11100,
        shipping_city:     "Narbonne"
      )

      expect(result.attributes).to include(
        use_billing_address: false,
        shipping_zip:        "11100",
        shipping_city:       "Narbonne"
      )
    end

    it "keeps real email addresses unchanged" do
      result = map

      expect(result.attributes[:email]).to eq("marc.mercier@example.fr")
      expect(result.warnings).to be_empty
    end

    it "treats the placeholder email address as missing and flags it" do
      result = map(email: "contact@baqio.fake")

      expect(result.attributes[:email]).to be_nil
      expect(result.warnings).not_to be_empty
    end
  end
end