# -*- encoding: utf-8 -*-
require 'strscan'
require 'rehtml/elements'

module REHTML
  module ParseInfo
    attr_reader :raw, :start_pos, :end_pos
    def set_pares_info(bpos,scanner)
      @start_pos=bpos
      @end_pos= scanner.pos
      @raw = scanner.string[@start_pos...(@end_pos)]
    end
  end
  class Tokenizer
    class Scanner < StringScanner
      def scan_before_or_eos(regex, move_after=false)
        self.scan_before(regex, true, move_after)
      end
      def scan_before(regex, or_eos=false, move_after=false)
        text = self.scan_until(regex)
        if text
          size = self.matched.size
          self.pos -= size unless move_after
          return text[0...(-size)]
        end
        if or_eos
          text = self.rest
          self.terminate
        end
        text
      end
    end
    # Create a new Tokenizer for the given text.
    def initialize(html)
      @scanner = Scanner.new(html)
      @bpos = 0
    end

    # Return the next token in the sequence, or +nil+ if there are no more tokens in
    # the stream.
    def next
      return nil if @scanner.eos?
      add_parse_info(@scanner.check(/<\S/) ? scan_element : scan_text)
    end

    private
    def add_parse_info(node)
      node.extend(ParseInfo)
      node.set_pares_info(@bpos,@scanner)
      @bpos = @scanner.pos
      node
    end

    def scan_text
      Text.new(decode("#{@scanner.getch}#{@scanner.scan(/[^<]*/)}"))
    end

    # decode html entity
    def decode(html)
      # TODO:
      html
    end

    def scan_element
      if @scanner.scan(/<!--/) # comment
        comment = @scanner.scan_before_or_eos(/-->/,true)
        Comment.new(comment)
      elsif @scanner.scan(/<!\[CDATA\[/)
        CData.new(@scanner.scan_before_or_eos(/\]\]>/,true))
      elsif @scanner.scan(/<!DOCTYPE[\x09\x0A\x0C\x0D]+/)
        scan_doctype
      elsif @scanner.scan(/<!/) # comment
        comment = @scanner.scan_before_or_eos(/>/,true)
        Comment.new(comment)
      elsif @scanner.scan(/<\?/) # PI or xml decl 
        scan_pi
      else
        scan_tag
      end
    end

    def scan_tag
      @scanner.scan(/<(\/)?([^\x20\x09\x0A\x0C\x0D>]*)/)
      is_end = @scanner[1] ? true : false
      name = @scanner[2]
      attrs = {}
      loop do
        @scanner.skip(/[\x20\x09\x0A\x0C\x0D]/)
        attr = @scanner.scan_before_or_eos(/[=>\x20\x09\x0A\x0C\x0D]|\/>/)
        matched = @scanner.matched
        if matched == '>' || matched.nil? || matched == '/>'
          attrs[attr.downcase]="" unless attr.empty?
          break
        end
        @scanner.skip(/[\x20\x09\x0A\x0C\x0D]/)
        if @scanner.scan(/=/)
          @scanner.skip(/[\x20\x09\x0A\x0C\x0D]/)
          if @scanner.scan(/['"]/)
            m = Regexp.compile(Regexp.quote(@scanner.matched))
            value = @scanner.scan_before_or_eos(m, true)
          else
            value = @scanner.scan_before_or_eos(/[>\x20\x09\x0A\x0C\x0D]|\/>/)
          end
        else 
          value = ""
        end
        attrs[attr.downcase]=decode(value) unless attr.empty?
      end
      empty = !@scanner.scan(/\//).nil?
      @scanner.skip(/>/)
      if is_end
        EndTag.new(name.downcase,attrs,empty)
      else
        Tag.new(name.downcase,attrs,empty)
      end
    end
    def scan_pi
      # http://www.w3.org/TR/REC-xml/#NT-Name 
      name = @scanner.scan(/([-:A-Z_a-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD0-9\u00B7\u0300-\u036F\u203F-\u2040]+)/) || ""
      body = @scanner.scan_before_or_eos(/\?>/,true)
      Instruction.new(name,body)
    end
    def scan_doctype
      # TODO complex doctype
      # https://github.com/ruby/ruby/blob/master/lib/rexml/parsers/baseparser.rb#L258
      # source = REXML::Source.new(doctype)
      # parser = REXML::Parsers::BaseParser.new(soucre)
      # while parser.document_status == in_doctype
      #   parser.pull_event
      doctype = @scanner.scan_before_or_eos(/>/,true)
      DocType.new
    end
  end
end
