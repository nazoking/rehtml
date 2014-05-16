require 'spec_helper'
require 'rehtml/tokenizer'

describe REHTML::Tokenizer do
  describe "scan aabcd" do
    let(:scanner){ REHTML::Tokenizer::Scanner.new("aabcd") }
    it "scan_before" do
      expect(scanner.scan_before(/b/)).to eq("aa")
      expect(scanner.check(/b/)).to eq("b")
      expect(scanner.scan(/b/)).to eq("b")
      expect(scanner.scan(/b/)).to eq(nil)
    end
    it "scan_before_or_eos" do
      expect(scanner.scan_before_or_eos(/z/)).to eq("aabcd")
      expect(scanner.eos?).to eq(true)
    end
    it "scan_before_or_eos move_after" do
      expect(scanner.scan_before_or_eos(/b/,true)).to eq("aa")
      expect(scanner.rest).to eq("cd")
    end
  end

  describe %[<a name="be evil" type='checkbox' value=yes disabled>] do
    before(:each) do
      @tokenizer =  REHTML::Tokenizer.new(%[<a name="be evil" type='checkbox' value=yes disabled>])
    end
    describe "first" do
      subject(:first) { @tokenizer.next.to_rexml }
      it{ should be_a(REXML::Element) }
      its(:name){ should eq("a") }
      describe "attribute" do
        subject { @tokenizer.next.attributes }
        its(["type"]){ should eq("checkbox") }
        its(["name"]){ should eq("be evil") }
        its(["value"]){ should eq("yes") }
        its(["disabled"]){ should eq("") }
      end
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
      subject{ @token1.to_rexml }
      it{ should be_a(REXML::Text) }
      its(:value){ should eq("a") }
    end
    context "token2" do
      subject{ @token2.to_rexml }
      it{ should be_a(REXML::Element) }
      its(:name){ should eq("b") }
    end
    context "token3" do
      subject{ @token3.to_rexml }
      it{ should be_a(REXML::Text) }
      its(:value){ should eq("c") }
    end
    context "token4" do
      subject{ @token4 }
      it{ should be_a(REHTML::EndTag) }
      its(:name){ should eq("b") }
    end
    context "token5" do
      subject{ @token5.to_rexml }
      it{ should be_a(REXML::Text) }
      its(:value){ should eq("d") }
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
      subject{ @token1.to_rexml }
      it{ should be_a(REXML::XMLDecl) }
      its(:version){ should eq("1.0") }
    end
    context "token2" do
      subject{ @token2.to_rexml }
      it{ should be_a(REXML::Instruction) }
      its(:target){ should eq("php") }
      its(:content){ should eq("hoge") }
    end
    context "token3" do
      subject{ @token3.to_rexml }
      it{ should be_a(REXML::Instruction) }
      its(:target){ should eq("") }
      its(:content){ should eq("huga") }
    end
  end
  describe %{<!-- comment --><![CDATA[ cdata ]]>} do
    before(:each) do
      @tokenizer = REHTML::Tokenizer.new(%{<!-- comment --><![CDATA[ cdata ]]>})
      @token1 = @tokenizer.next
      @token2 = @tokenizer.next
    end
    context "token1" do
      subject{ @token1.to_rexml }
      it{ should be_a(REXML::Comment) }
      its(:string){ should eq(" comment ") }
    end
    context "token2" do
      subject{ @token2.to_rexml }
      it{ should be_a(REXML::CData) }
      its(:value){ should eq(" cdata ") }
    end
  end
end
