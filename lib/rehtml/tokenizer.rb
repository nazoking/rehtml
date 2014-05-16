# -*- encoding: utf-8 -*-
require 'strscan'
require 'rehtml/elements'

module REHTML
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
    end

    # Return the next token in the sequence, or +nil+ if there are no more tokens in
    # the stream.
    def next
      return nil if @scanner.eos?
      if @scanner.check(/<\S/)
        scan_element
      else
        scan_text
      end
    end

    private

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
      elsif @scanner.scan(/<!DOCTYPE/) # doctype
        doctype = @scanner.scan_before_or_eos(/>/,true)
        DocType.new(doctype)
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
        if matched =='>' || matched.nil?
          attrs[attr]="" unless attr.nil?
          break
        end
        @scanner.skip(/[\x20\x09\x0A\x0C\x0D]/)
        if @scanner.scan(/=/)
          @scanner.skip(/[\x20\x09\x0A\x0C\x0D]/)
          if @scanner.scan(/['"]/)
            value = @scanner.scan_before_or_eos(Regexp.compile(@scanner.matched))
          else
            value = @scanner.scan_before_or_eos(/[>\x20\x09\x0A\x0C\x0D]|\/>/)
          end
        else 
          value = ""
        end
        attrs[attr.downcase]=decode(value) unless attr.nil?
      end
      @scanner.skip(/(\/)?>/)
      empty = @scanner[1]
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
  end
end
