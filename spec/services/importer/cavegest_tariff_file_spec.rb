require "spec_helper"

RSpec.describe Importer::CavegestTariffFile do
  subject(:file) { described_class.new(data_path("export_tarifs_cavegest.csv")) }

  describe "#rows" do
    it "reads every product line in the file" do
      expect(file.rows.size).to eq(113)
    end

    it "decodes accented characters" do
      designations = file.rows.map { |row| row.values["Désignation"] }

      expect(designations).to include(a_string_matching(/é/))
    end

    it "reads the header from the third line, not the title line" do
      expect(file.rows.first.values.keys).to include("Ref", "Désignation", "Contenant", "DEPC")
    end

    it "skips section headers and subtotal lines" do
      references = file.rows.map { |row| row.values["Ref"] }

      expect(references).to all(satisfy { |ref| !ref.start_with?("---", "SOUS-TOTAL") })
    end

    it "reports the line number as seen in the raw file" do
      expect(file.rows.first.line_number).to eq(5)
    end

    it "tags each row with the section it belongs to" do
      expect(file.rows.first.section).to eq("AOP ROUGES")
    end
  end

  describe "#section_totals" do
    it "reads the count announced at the end of each section" do
      expect(file.section_totals).to eq(
        "AOP ROUGES"    => 14,
        "AOP BLANCS"    => 16,
        "IGP"           => 18,
        "VIN DE FRANCE" => 22,
        "EFFERVESCENTS" => 21,
        "DIVERS"        => 22
      )
    end
  end
end