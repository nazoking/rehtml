require 'spec_helper'
require 'rehtml/parser'

class ReHTML
  def initialize(str)
    @str = str
  end
  def to_s
    @str
  end
  def to_rexml
    REHTML.to_rexml(@str).to_s
  end
  def doc
    REHTML.to_rexml(@str)
  end
end
def ReHTML(str)
  ReHTML.new(str)
end

describe ReHTML(%[ <title>html</title> <a>a</a>]) do
  its(:to_rexml){ should eq(%[ <html><title>html</title> <a>a</a></html>]) }
end
describe ReHTML(%[<a>html</a>]) do
  its(:to_rexml){ should eq(%[<a>html</a>]) }
end
describe ReHTML(%[<title>html</title><a>a</a>]) do
  its(:to_rexml){ should eq(%[<html><title>html</title><a>a</a></html>]) }
  its("doc.xml_decl.writethis"){ should be_false } 
end
describe ReHTML(%[  <?xml version="1.0" ?><html><a>a</a>]) do
  its(:to_rexml){ should eq(%[<?xml version='1.0'?>  <html><a>a</a></html>]) }
  its("doc.xml_decl.writethis"){ should be_true } 
end
describe ReHTML(%[<html><a />]) do
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
