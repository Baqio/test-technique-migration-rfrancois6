require "spec_helper"

RSpec.describe Importer::CavegestCustomerFile do
  subject(:file) { described_class.new(data_path("export_clients_cavegest.xlsx")) }

  describe "#rows" do
    it "reads every customer line in the file" do
      expect(file.rows.size).to eq(4997)
    end

    it "finds no row with reference containing TOTAL" do
      expect(file.rows.map { |row| row.values[:reference] }).not_to include(a_string_matching(/TOTAL/))
    end

    it "keeps billing and shipping columns apart" do
      row = file.rows.find { |r| r.values[:reference] == "T00013" }

      expect(row.values).to include(
        zip:           4000,
        city:          "Digne-les-Bains",
        shipping_zip:  11100,
        shipping_city: "Narbonne"
      )
    end

    it "finds a customer with filled billing address but no shipping address" do
      row = file.rows.find { |r| r.values[:reference] == "T00001" }

      expect(row.values).to include(
        zip:           69002,
        city:          "Lyon",
        shipping_zip:  nil,
        shipping_city: nil
      )
    end

    it "reports the line number as seen in the raw file" do
      expect(file.rows.first.line_number).to eq(2)
    end

    it "keeps raw values for each column" do
      row = file.rows.find { |r| r.values[:reference] == "T00013" }
      expect(row.values[:zip]).to eq(4000)
    end

    it "reads the real data sheet, not the backup one" do
      company_names = file.rows.map { |row| row.values[:company_name] }
      expect(company_names).not_to include(a_string_matching(/ANCIEN LIBELLE/))
    end
  end
  
  describe "#announced_total" do
    it "calculates the total number of customers" do
      expect(file.announced_total).to eq(5000)
    end
  end
end