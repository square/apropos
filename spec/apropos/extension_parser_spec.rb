require_relative "../spec_helper.rb"

describe Apropos::ExtensionParser do
  before :each do
    described_class.parsers.clear
  end

  describe ".parsers" do
    it "keeps track of variant parsers" do
      parser = described_class.add_parser('2x') do
      end
      described_class.parsers['2x'].should == parser
      described_class.parsers.count.should == 1
    end
  end

  describe ".add_parser" do
    it "overrides previously defined parsers with the same extension" do
      old_parser = described_class.add_parser('2x')
      new_parser = described_class.add_parser('2x')
      described_class.parsers['2x'].should == new_parser
    end
  end

  describe ".each_parser" do
    it "yields each parser to the block" do
      described_class.add_parser('2x')
      described_class.add_parser('medium')
      described_class.add_parser('fr')
      vals = []
      described_class.each_parser do |parser|
        vals << parser.pattern
      end
      vals.should == %w[2x medium fr]
    end
  end

  describe "#match" do
    let(:locale_pattern) { /^([a-z]{2})$/ }

    it "calls the block when the extension matches" do
      lastmatch = nil
      parser = described_class.new(locale_pattern) do |match|
        lastmatch = match
      end
      parser.match('fr')
      lastmatch[1].should == 'fr'
    end

    it "doesn't call the block when there is no match" do
      expect {
        parser = described_class.new(/^fr$/) do |match|
          raise
        end
        parser.match('en').should be_nil
      }.to_not raise_error
    end

    it "allows the block to return a nil value" do
      parser = described_class.new(locale_pattern) do |match|
        if match[1] == 'fr'
          true
        else
          nil
        end
      end
      parser.match('fr').should == true
      parser.match('en').should be_nil
    end
  end
end
