require 'spec_helper'
require 'rehtml/scanner'
describe REHTML::Scanner do
  describe "scan aabcd" do
    let(:scanner){ REHTML::Scanner.new("aabcd") }
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
end
