require_relative "../spec_helper.rb"

describe Apropos::Set do
  subject { described_class.new("foo.jpg", "/dir") }

  it "detects paths with indicators before the base file extension" do
    subject.variant_path_glob.should == Pathname.new("foo.*.jpg")
  end

  it "generates a list of variant paths and code fragments" do
    paths = {
      "ca" => "foo.ca.jpg",
      "2x" => "foo.2x.jpg",
      "large.fr" => "foo.large.fr.jpg",
      "large.2x.ca" => "foo.large.2x.ca.jpg",
    }
    globbed = paths.values.map {|path| "/dir/#{path}"}
    Dir.should_receive(:glob).with(Pathname.new("/dir/foo.*.jpg")).and_return(globbed)
    subject.variant_paths.should == paths
  end

  it "creates Variants from variant paths and code fragments" do
    Dir.should_receive(:glob).and_return(["/dir/foo.ca.jpg"])
    Apropos::Variant.should_receive(:new).with("ca", "foo.ca.jpg")
    subject.variants.length.should == 1
  end

  it "removes the basedir from paths" do
    set = described_class.new("foo.jpg", "/foo/bar")
    set.remove_basedir("/Users/bob/foo/bar/foo.fr.jpg").should == "foo.fr.jpg"
  end
end
