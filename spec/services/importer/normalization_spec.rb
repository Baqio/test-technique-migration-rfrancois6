require "spec_helper"

RSpec.describe Importer::Normalization do
  describe ".decimal" do
    it "parses French decimal separators" do
      expect(described_class.decimal("13,32")).to eq(BigDecimal("13.32"))
      expect(described_class.decimal("5,50")).to eq(BigDecimal("5.5"))
    end

    it "parses plain integers" do
      expect(described_class.decimal("13")).to eq(BigDecimal("13"))
    end

    it "strips whitespace and currency suffixes" do
      expect(described_class.decimal("  19,31 EUR")).to eq(BigDecimal("19.31"))
    end

    it "strips percent signs" do
      expect(described_class.decimal("20%")).to eq(BigDecimal("20"))
    end

    it "returns a BigDecimal, never a Float" do
      expect(described_class.decimal("13,32")).to be_a(BigDecimal)
    end

    it "returns nil for blank values" do
      expect(described_class.decimal(nil)).to be_nil
      expect(described_class.decimal("")).to be_nil
      expect(described_class.decimal("   ")).to be_nil
    end

    it "returns nil for values it cannot read" do
      expect(described_class.decimal("abc")).to be_nil
    end
  end

  describe ".zip" do
    it "returns with initial 0 and in string format for French zip codes" do
      expect(described_class.zip(1234, "FR")).to eq("01234")
    end

    it "returns right zip codes in string format for other countries" do
      expect(described_class.zip(9000, "BE")).to eq("9000")
    end

    it "returns zip codes in string format if zip is rightly formatted" do
      expect(described_class.zip(69002, "FR")).to eq("69002")
    end

    it "returns nil for nil/blank values" do
      expect(described_class.zip(nil)).to be_nil
      expect(described_class.zip("")).to be_nil
      expect(described_class.zip("   ")).to be_nil
    end
  end

  describe ".country_code" do
    it "keeps valid ISO codes unchanged" do
      expect(described_class.country_code("FR")).to eq("FR")
      expect(described_class.country_code("BE")).to eq("BE")
      expect(described_class.country_code("DE")).to eq("DE")
    end

    it "translates French country names into ISO codes" do
      expect(described_class.country_code("FRANCE")).to eq("FR")
      expect(described_class.country_code("france")).to eq("FR")
      expect(described_class.country_code("France ")).to eq("FR")
      expect(described_class.country_code("fr")).to eq("FR")
      expect(described_class.country_code("Allemagne")).to eq("DE")
      expect(described_class.country_code("allemagne")).to eq("DE")
      expect(described_class.country_code("Belgique")).to eq("BE")
    end

    it "returns nil for unknown country names" do
      expect(described_class.country_code("Suisse")).to be_nil 
    end

    it "returns nil for nil/blank values" do
      expect(described_class.country_code(nil)).to be_nil
      expect(described_class.country_code("")).to be_nil
      expect(described_class.country_code("   ")).to be_nil
    end
  end
end