require_relative "../spec_helper.rb"

describe Apropos::ClassList do
  it "combines class lists" do
    combo = described_class.new([".foo"]).combine(described_class.new([".bar"]))
    combo.to_css.should == ".foo, .bar"
  end
end
