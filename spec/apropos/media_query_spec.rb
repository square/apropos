require_relative "../spec_helper.rb"

describe Apropos::MediaQuery do
  it "wraps query in parens" do
    css = described_class.new("min-width: 320px").to_css
    css.should == "(min-width: 320px)"
  end

  it "combines media queries" do
    combo = described_class.new("min-width: 320px").combine(described_class.new("max-width: 480px"))
    combo.to_css.should == "(min-width: 320px) and (max-width: 480px)"
  end

  it "parses comma-separated media queries" do
    query = described_class.new("min-width: 320px, min-resolution: 192dpi")
    query.to_css.should == "(min-width: 320px), (min-resolution: 192dpi)"
  end

  it "combines complex media query strings" do
    base = described_class.new("(-webkit-min-device-pixel-ratio: 2), (min-resolution: 192dpi)")
    combo = base.combine(described_class.new("min-width: 320px"))
    combo.to_css.should == "(-webkit-min-device-pixel-ratio: 2) and (min-width: 320px), (min-resolution: 192dpi) and (min-width: 320px)"
  end
end
