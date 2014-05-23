require 'rehtml/tokenizer'
require 'rehtml/builder'

module REHTML
  def self.to_rexml(str)
    builder = REXMLBuilder.new
    builder.parse(Tokenizer.new(str))
    builder.doc
  end

  private

  def self.node_to_remlx(html)
    ret = html.to_rexml
    if html.is_a?(Parent)
      for node in html.children
        ret << node_to_remlx(node)
      end
    end
    ret
  end
end
