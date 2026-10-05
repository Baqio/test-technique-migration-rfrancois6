module Importer
  Issue = Struct.new(:field, :message, :raw_value, keyword_init: true)
end