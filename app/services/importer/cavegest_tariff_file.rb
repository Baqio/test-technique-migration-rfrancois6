class Importer::CavegestTariffFile
  Row = Struct.new(:line_number, :section, :values, keyword_init: true)

  def initialize(path)
    @path = path
  end

  def rows
    parse!
    @rows_data
  end

  def section_totals
    parse!
    @section_totals
  end

  private

  def parse!
    return if @parsed

    @rows_data      = []
    @section_totals = {}

    # skip the first three lines (title + header + empty line), if any change, please verify headers line too
    raw_rows[3..].each_with_index do |row, index| 
      next if row.all?(&:blank?) # skip empty lines

      if row[0].start_with?("---")
        @current_section = row[0].delete("-").strip
      elsif row[0].start_with?("SOUS-TOTAL")
        @section_totals[@current_section] = row.last.to_i
      else
        @rows_data << build_row(row, index)
      end
    end

    @parsed = true
  end

  def build_row(row, index)
    Row.new(
      line_number: index + 4, # index 0 corresponds to line 4 in the raw file
      section:     @current_section,
      values:      headers.zip(row).to_h
    )
  end

  def raw_rows
    @raw_rows ||= CSV.read(@path, col_sep: ";", encoding: "ISO-8859-1:UTF-8").map do |row|
      row.map { |cell| cell.to_s.strip }
    end
  end

  def headers
    @headers ||= raw_rows[2] # the third line of the file contains the headers
  end
end