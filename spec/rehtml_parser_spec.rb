require 'spec_helper'
require 'rehtml'

class ReHTML
  def initialize(str)
    @str = str
  end
  def to_s
    "parse [#{@str}]"
  end
  def to_rexml
    REHTML.to_rexml(@str).to_s
  end
  def doc
    REHTML.to_rexml(@str)
  end
end
def parse(str)
  ReHTML.new(str)
end

describe parse(%[ <title>html</title> <a>a</a>]) do
  its(:to_rexml){ should eq(%[ <html><title>html</title> <a>a</a></html>]) }
end
describe parse(%[<a>html</a>]) do
  its(:to_rexml){ should eq(%[<a>html</a>]) }
end
describe parse(%[<title>html</title><a>a</a>]) do
  its(:to_rexml){ should eq(%[<html><title>html</title><a>a</a></html>]) }
  its("doc.xml_decl.writethis"){ should be_false } 
end
describe parse(%[  <?xml version="1.0" ?><html><a>a</a>]) do
  its(:to_rexml){ should eq(%[<?xml version='1.0'?>  <html><a>a</a></html>]) }
  its("doc.xml_decl.writethis"){ should be_true } 
end
describe parse(%[<html><a />]) do
  its(:to_rexml){ should eq(%[<html><a/></html>]) }
end
=begin
  describe %[index.jsp] do
    it{
       doc = REHTML.to_rexml(open(File.join(File.dirname(__FILE__),'files','login.jsp')).read)
       formatter = REXML::Formatters::Pretty.new
       formatter.write(doc.root, $stdout)
    }
  end
=end
