require 'spec_helper'
require 'rehtml/tokenizer'

describe REHTML::Tokenizer do
  describe %[<a name="be evil" type='checkbox' value=yes disabled>] do
    before(:each) do
      @tokenizer =  REHTML::Tokenizer.new(%[<a name="be evil" type='checkbox' value=yes disabled>])
    end
    describe "first" do
      subject(:first) { @tokenizer.next }
      its(:raw){ should eq(%[<a name="be evil" type='checkbox' value=yes disabled>]) }
      it{ should be_a(REHTML::Tag) }
      its(:name){ should eq("a") }
      its(:attributes){ should eq({
        "type"=>"checkbox",
        "name"=>"be evil",
        "value"=>"yes",
        "disabled"=>""}) }
    end
    describe "second" do
      subject{ @tokenizer.next; @tokenizer.next }
      it{ should be_nil }
    end
  end
  describe %[a<b>c</b>d] do
    before(:each) do
      @tokenizer =  REHTML::Tokenizer.new(%[a<b>c</b>d])
      @token1 = @tokenizer.next
      @token2 = @tokenizer.next
      @token3 = @tokenizer.next
      @token4 = @tokenizer.next
      @token5 = @tokenizer.next
      @token6 = @tokenizer.next
    end
    context "token1" do
      subject{ @token1 }
      its(:raw){ should eq("a") }
      it{ should be_a(REHTML::Text) }
      its(:value){ should eq("a") }
    end
    context "token2" do
      subject{ @token2 }
      its(:raw){ should eq("<b>") }
      it{ should be_a(REHTML::Tag) }
      its(:name){ should eq("b") }
      its("attributes.empty?"){ should be_true }
    end
    context "token3" do
      subject{ @token3 }
      it{ should be_a(REHTML::Text) }
      its(:value){ should eq("c") }
    end
    context "token4" do
      subject{ @token4 }
      it{ should be_a(REHTML::EndTag) }
      its(:name){ should eq("b") }
    end
    context "token5" do
      subject{ @token5 }
      it{ should be_a(REHTML::Text) }
      its(:value){ should eq("d") }
    end
    context "token6" do
      subject{ @token6 }
      it{ should be_nil }
    end
  end
  describe %[<?xml version="1.0"?><?php hoge?><? huga?>] do
    before(:each) do
      @tokenizer = REHTML::Tokenizer.new(%[<?xml version=1?><?php hoge?><? huga?>])
      @token1 = @tokenizer.next
      @token2 = @tokenizer.next
      @token3 = @tokenizer.next
    end
    context "token1" do
      subject{ @token1 }
      it{ should be_a(REHTML::Instruction) }
      its(:is_xml_decl?){ should be_true }
    end
    context "token2" do
      subject{ @token2 }
      it{ should be_a(REHTML::Instruction) }
      its(:target){ should eq("php") }
      its(:content){ should eq(" hoge") }
    end
    context "token3" do
      subject{ @token3 }
      it{ should be_a(REHTML::Instruction) }
      its(:target){ should eq("") }
      its(:content){ should eq(" huga") }
    end
  end
  describe %{<!-- comment --><![CDATA[ cdata ]]>} do
    before(:each) do
      @tokenizer = REHTML::Tokenizer.new(%{<!-- comment --><![CDATA[ cdata ]]>})
      @token1 = @tokenizer.next
      @token2 = @tokenizer.next
    end
    context "token1" do
      subject{ @token1 }
      it{ should be_a(REHTML::Comment) }
      its(:string){ should eq(" comment ") }
    end
    context "token2" do
      subject{ @token2 }
      it{ should be_a(REHTML::CData) }
      its(:value){ should eq(" cdata ") }
    end
  end
  describe %{unclosed comment <!-- comment } do
    before(:each) do
      @t = REHTML::Tokenizer.new(%{<!-- comment })
      @t1 = @t.next
      @t2 = @t.next
    end
    context "token1" do
      subject{ @t1 }
      it{ should be_a(REHTML::Comment) }
      its(:string){ should eq(" comment ") }
    end
    it("token2 should be nil"){ @t2.should be_nil }
  end
  describe %{unclosed tag <A } do
    before(:each) do
      @t = REHTML::Tokenizer.new(%{<A })
      @t1 = @t.next
      @t2 = @t.next
    end
    context "token1" do
      subject{ @t1 }
      it{ should be_a(REHTML::Tag) }
      its(:name){ should eq("a") }
      its(:attributes){ should be_empty }
    end
    it("token2 should be nil"){ @t2.should be_nil }
  end
  describe %{bad <A =A=B ATTR x=">" hoge = ' huge} do
    before(:each) do
      @t = REHTML::Tokenizer.new(%{<A =A=B ATTR x=">" A =A=B hoge = ' huge})
      @t1 = @t.next
      @t2 = @t.next
    end
    context "token1" do
      subject{ @t1 }
      it{ should be_a(REHTML::Tag) }
      its(:name){ should eq("a") }
      its(:attributes){ should eq({"attr"=>"", "hoge"=>" huge", "a"=>"A=B","x"=>">"}) }
    end
    it("token2 should be nil"){ @t2.should be_nil }
  end
end
