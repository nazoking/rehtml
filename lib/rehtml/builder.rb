module REHTML
  class REXMLBuilder
    EMPTY_TAGS=Set.new %w[br img hr meta input embed area base col keygen link param source isindex basefont]
    CDATA_TAGS=Set.new %w[script style textarea xmp title]
    attr_reader :doc
    def initialize
      @doc = REXML::Document.new
      @pos = @doc
    end
    def parse(tokenizer)
      while node=tokenizer.next
        append(node)
      end
    end
    def to_rexml(node)
      case node
      when Text
        REXML::Text.new(node.value)
      when CData
        REXML::CData.new(node.value)
      when Instruction
        if node.is_xml_decl? and ( @doc.xml_decl.nil? or !@doc.xml_decl.writethis )
          begin
            return REXML::Document.new("<?xml #{node.content}?>").xml_decl
          rescue REXML::ParseException
          end
        end
        REXML::Instruction.new(node.target,node.content)
      when DocType
        REXML::Comment.new(node.raw)
      when Comment
        REXML::Comment.new(node.string)
      when Tag
        if cdata_tag?(@pos.name)
          REXML::Text.new(node.raw)
        else
          xml = REXML::Element.new
          xml.name = node.name
          xml.add_attributes(node.attributes)
          xml
        end
      else
        raise "unknown node type #{node}"
      end
    end
    def append(node)
      if node.is_a?(EndTag)
        return if empty_tag?(node.name)
        po = @pos
        while po.parent and po.name != node.name
          po = po.parent
        end
        if po.name == node.name
          @pos = po.parent
        end
      else
        rexml = to_rexml(node)

        # if second root
        if rexml.is_a?(REXML::Element) and @pos == @doc and @doc.root
          if @doc.root.name != 'html'
            html = REXML::Element.new
            html.name = "html"
            i = @doc.root.index_in_parent-1
            while pos = @doc.delete_at(i)
              @doc.delete_element(pos) if pos.is_a?(REXML::Element)
              html << pos
            end
            @doc << html
            @pos = html
          end
          @pos = @doc.root
        end
        @pos << rexml
        if rexml.is_a?(REXML::Element) and !empty_tag?(node.name) and !node.empty?
          @pos = rexml
        end
      end
    end
    def empty_tag?(tagname)
      EMPTY_TAGS.include?(tagname)
    end
    def cdata_tag?(tagname)
      CDATA_TAGS.include?(tagname)
    end
  end
end
