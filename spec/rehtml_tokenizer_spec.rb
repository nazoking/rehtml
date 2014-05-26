# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'rehtml/tokenizer'

class TokenizeHelper
  def initialize(msg,str=nil);
    @msg = str.nil? ? "" : " #{msg}"
    @str = str.nil? ? msg : str
  end
  def to_s; "tokenize#{@msg} {#{@str}}"; end
  def first_token; REHTML::Tokenizer.new(@str).next; end
  def token_size
    t = REHTML::Tokenizer.new(@str)
    i = 0
    i += 1 until t.next.nil?
    i
  end
  def token(num)
    t = REHTML::Tokenizer.new(@str)
    num.times{|ii|
      token = t.next
      raise "token size is #{ii}" if token.nil?
    }
    t.next
  end
  def method_missing(name, *args)
    if name.to_s =~ /^token(\d+)$/
      token($1.to_i-1)
    else
      first_token.send(name, *args)
    end
  end
end
def tokenize(msg,str=nil); TokenizeHelper.new(msg,str); end

describe tokenize(%[<a name="be evil" type='checkbox' value=yes disabled>]) do
  its("first_token.raw"){ should eq(%[<a name="be evil" type='checkbox' value=yes disabled>]) }
  its("first_token"){ should be_a(REHTML::Tag) }
  its(:name){ should eq("a") }
  its(:attributes){ should eq({
    "type"=>"checkbox",
    "name"=>"be evil",
    "value"=>"yes",
    "disabled"=>""}) }
  its(:token_size){ should eq(1) }
end
describe tokenize(%[<?xml version="1.0"?>]) do
  its(:first_token){ should be_a(REHTML::Instruction) }
  its(:first_token){ should be_is_xml_decl }
  its(:token_size){ should eq(1) }
end
describe tokenize(%[<?php hoge?>]) do
  its(:token_size){ should eq(1) }
  its(:first_token){ should be_a(REHTML::Instruction) }
  its(:target){ should eq("php") }
  its(:content){ should eq(" hoge") }
  it{ should_not be_is_xml_decl }
end
describe tokenize(%[<? huga?>]) do
  its(:token_size){ should eq(1) }
  its(:first_token){ should be_a(REHTML::Instruction) }
  its(:target){ should eq("") }
  its(:content){ should eq(" huga") }
  it{ should_not be_is_xml_decl }
end
describe tokenize(%{<!-- comment -->}) do
  its(:token_size){ should eq(1) }
  its(:first_token){ should be_a(REHTML::Comment) }
  its("first_token.string"){ should eq(" comment ") }
end
describe tokenize(%{abc &a; &amp; &amp &#x2212; &#39; }) do
  its(:token_size){ should eq(1) }
  its(:first_token){ should be_a(REHTML::Text) }
  its(:value){ should eq(%[abc &a; & &amp − ' ]) }
end
describe tokenize(%{<![CDATA[ cdata ]]>}) do
  its(:token_size){ should eq(1) }
  its(:first_token){ should be_a(REHTML::CData) }
  its(:value){ should eq(" cdata ") }
end
describe tokenize("unclosed comment",%[<!-- comment]) do
  its(:token_size){ should eq(1) }
  its(:first_token){ should be_a(REHTML::Comment) }
  its(:string){ should eq(" comment") }
end
describe tokenize("unclosed tag",%{<A }) do
  its(:token_size){ should eq(1) }
  its(:first_token){ should be_a(REHTML::Tag) }
  its(:name){ should eq("a") }
  its(:attributes){ should be_empty }
end
describe tokenize(%{<A =A=B ATTR x=">" A =A=B hoge = ' huge}) do
  its(:first_token){ should be_a(REHTML::Tag) }
  its(:name){ should eq("a") }
  its(:attributes){ should eq({"attr"=>"", "hoge"=>" huge", "a"=>"A=B","x"=>">"}) }
end
describe tokenize(%{<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">}) do
  its(:token_size){ should eq(1) }
  its(:first_token){ should be_a(REHTML::DocType) }
  its("token1.raw"){ should eq(%{<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">}) }
end
describe tokenize(%{<!BAD "//www.w3.org/TR/html4/loose.dtd">}) do
  its(:token_size){ should eq(1) }
  its(:first_token){ should be_a(REHTML::Comment) }
  its(:string){ should eq('BAD "//www.w3.org/TR/html4/loose.dtd"') }
end
describe tokenize(%[a<b>c</b>d]) do
  its("token1.raw"){ should eq("a") }
  its("token1"){ should be_a(REHTML::Text) }
  its("token1.value"){ should eq("a") }
  its("token2.raw"){ should eq("<b>") }
  its("token2"){ should be_a(REHTML::Tag) }
  its("token2.name"){ should eq("b") }
  its("token2.attributes"){ should be_empty }
  its("token3"){ should be_a(REHTML::Text) }
  its("token3.value"){ should eq("c") }
  its("token4"){ should be_a(REHTML::EndTag) }
  its("token4.name"){ should eq("b") }
  its("token5"){ should be_a(REHTML::Text) }
  its("token5.value"){ should eq("d") }
  its("token6"){ should be_nil }
end
