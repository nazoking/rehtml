require 'rexml/document'
module REHTML
  module ParseInfo
    attr :raw, :start_pos, :end_pos
  end
  class Node
  end
  class Text < Node
    attr :value
    def initialize(value)
      @value = value
    end
    def to_rexml
      REXML::Text.new(value)
    end
  end
  class CData < Text
    def to_rexml
      REXML::CData.new(value)
    end
  end
  class Tag < Node
    attr :name, :attributes, :empty
    def initialize(name,attributes,empty)
      @name = name
      @attributes = attributes
      @empty = empty
    end
    def to_rexml
      ret = REXML::Element.new
      ret.name = name
      ret.add_attributes(attributes)
      ret
    end
  end
  class EndTag < Tag
    def to_rexml
      nil
    end
  end
  class Instruction < Node
    attr :target, :content
    def initialize(target,content)
      @target = target
      @content = content
    end
    def is_xml_decl?
      target.upcase == 'XML'
    end
    def to_rexml
      if is_xml_decl?
        begin
          return REXML::Document.new("<?xml #{content}?>").xml_decl
        rescue REXML::ParseException
        end
      end
      REXML::Instruction.new(target,content)
    end
  end
  class Comment < Node
    attr :string
    def initialize(string)
      @string = string
    end
    def to_rexml
      REXML::Comment.new(string)
    end
  end
end
