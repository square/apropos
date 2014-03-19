require_relative "../spec_helper.rb"
require 'ostruct'

describe Apropos::Variant do
  let(:dummy_path) { "foo.jpg" }
  let!(:dpi_selector) { OpenStruct.new(:sort_value => 0) }
  let!(:breakpoint_selector) { OpenStruct.new(:sort_value => 1) }
  let!(:class_selector) { OpenStruct.new(:sort_value => 2) }

  def variant(code_fragment='')
    described_class.new(code_fragment, dummy_path)
  end

  before :all do
    Apropos::ExtensionParser.parsers.clear

    Apropos::ExtensionParser.add_parser('2x') do |match|
      dpi_selector
    end
    Apropos::ExtensionParser.add_parser('medium') do |match|
      breakpoint_selector
    end
    Apropos::ExtensionParser.add_parser(/^([a-z]{2})$/) do |match|
      class_selector
    end
  end

  after :all do
    Apropos::ExtensionParser.parsers.clear
  end

  it "extracts codes from code fragment" do
    variant("2x.medium.fr").codes.should == %w[2x medium fr]
  end

  it "collects conditions parsed from code fragment" do
    variant("2x").conditions.should == [dpi_selector]
    variant("2x.medium.fr").conditions.should == [dpi_selector, breakpoint_selector, class_selector]
  end

  it "is invalid if no conditions apply" do
    v = variant("1x")
    v.conditions.should == []
    v.should_not be_valid
    v.invalid_codes.should == %w[1x]
    v2 = variant("2x")
    v2.should be_valid
  end

  it "combines conditions of the same type" do
    v = variant
    v.stub(:conditions) {
      [
        Apropos::MediaQuery.new("min-width: 320px"),
        Apropos::MediaQuery.new("max-width: 640px")
      ]
    }
    v.rule.should == ["media", "(min-width: 320px) and (max-width: 640px)", "foo.jpg"]
  end

  it "combines conditions of different types" do
    v = variant
    v.stub(:conditions) {
      [
        Apropos::MediaQuery.new("min-width: 320px"),
        Apropos::ClassList.new([".foo"])
      ]
    }
    v.rule.should == ["class+media", ".foo", "(min-width: 320px)", "foo.jpg"]
  end

  it "aggregates the sort value of the rules" do
    variant("2x").aggregate_sort_value.should == 0
    variant("2x.medium").aggregate_sort_value.should == 1
    variant("2x.medium.fr").aggregate_sort_value.should == 3
  end
end
