require 'rehtml/tokenizer'
require 'rehtml/builder'

module REHTML
  def self.to_rexml(str)
    builder = REXMLBuilder.new
    builder.parse(Tokenizer.new(str))
    builder.doc
  end
end
