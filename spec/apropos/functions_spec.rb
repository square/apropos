require_relative "../spec_helper.rb"

describe Apropos do
  def stub_files(*files)
    Apropos::Set.stub(:glob).with(Pathname.new("#{images_dir}/foo.*.jpg")).and_return(files)
  end

  let(:images_dir) { '/project/images' }
  let(:project_dir) { nil }
  let(:rules) { Apropos.image_variant_rules("foo.jpg") }

  before do
    Compass.configuration.stub(:images_path).and_return(images_dir) if images_dir
    Compass.configuration.stub(:project_path).and_return(project_dir) if project_dir
  end

  describe ".add_class_image_variant" do
    after { Apropos.clear_image_variants }

    it "adds a simple class variant" do
      Apropos.add_class_image_variant('alt', 'alternate')
      stub_files("/foo.alt.jpg")
      rules.should == [
        ["class", ".alternate", "/foo.alt.jpg"]
      ]
    end

    it "adds multiple classes" do
      Apropos.add_class_image_variant('alt', ['alternate', 'alt'])
      stub_files("/foo.alt.jpg")
      rules.should == [
        ["class", ".alternate, .alt", "/foo.alt.jpg"]
      ]
    end

    it "respects sort order" do
      Apropos.add_class_image_variant('alt', 'alternate', 1)
      Apropos.add_class_image_variant('b', 'blue', 0)
      stub_files("/foo.alt.jpg", "/foo.b.jpg")
      rules.should == [
        ["class", ".blue", "/foo.b.jpg"],
        ["class", ".alternate", "/foo.alt.jpg"]
      ]
    end

    it "uses a custom block to generate class names" do
      Apropos.add_class_image_variant(/^[a-z]{2}$/) do |match|
        if match[0] == 'en'
          "lang-en"
        elsif match[0] == 'fr'
          ["lang-fr", "country-FR"]
        end
      end
      stub_files('/foo.en.jpg', '/foo.fr.jpg', '/foo.de.jpg')
      rules.should == [
        ["class", ".lang-en", "/foo.en.jpg"],
        [ "class", ".lang-fr, .country-FR", "/foo.fr.jpg"]
      ]
    end
  end

  describe ".image_variant_rules" do
    before :all do
      Apropos.add_dpi_image_variant('2x', "(-webkit-min-device-pixel-ratio: 2), (min-resolution: 192dpi)", 0.5)
      Apropos.add_breakpoint_image_variant('medium', 'min-width: 768px', 1)
      Apropos.add_breakpoint_image_variant('large', 'min-width: 1024px', 2)
      Apropos::ExtensionParser.add_parser(/^([a-z]{2}(?:-(ca))?)$/) do |match|
        if match[2]
          Apropos::ClassList.new([".locale-fr-CA"], 3)
        elsif match[1]
          if match[1] == 'fr'
            Apropos::ClassList.new([".lang-fr"], 2)
          elsif match[1] == 'ca'
            Apropos::ClassList.new([".country-CA"], 1)
          end
        else
          nil
        end
      end
    end

    after :all do
      Apropos.clear_image_variants
    end

    it "ignores invalid variants" do
      stub_files("/foo.1x.jpg", "/foo.de.jpg", "/foo.ca.jpg")
      rules.should == [
        ["class", ".country-CA", "/foo.ca.jpg"]
      ]
    end

    it "generates a locale class rule for localized variant" do
      stub_files("/foo.ca.jpg")
      rules.should == [
        ["class", ".country-CA", "/foo.ca.jpg"]
      ]
    end

    it "generates a media query rule for breakpoint variant" do
      stub_files("/foo.medium.jpg")
      rules.should == [
        ["media", "(min-width: 768px)", "/foo.medium.jpg"]
      ]
    end

    it "generates a media query rule for retina variant" do
      stub_files("/foo.2x.jpg")
      rules.should == [
        ["media", "(-webkit-min-device-pixel-ratio: 2), (min-resolution: 192dpi)", "/foo.2x.jpg"]
      ]
    end

    it "generates a combined rule for retina + localized variant" do
      stub_files("/foo.2x.ca.jpg")
      rules.should == [
        ["class+media", ".country-CA", "(-webkit-min-device-pixel-ratio: 2), (min-resolution: 192dpi)", "/foo.2x.ca.jpg"]
      ]
    end

    it "generates multiple rules for multiple variants" do
      stub_files("/foo.2x.ca.jpg", "/foo.medium.2x.fr.jpg")
      rules.should == [
        ["class+media", ".country-CA", "(-webkit-min-device-pixel-ratio: 2), (min-resolution: 192dpi)", "/foo.2x.ca.jpg"],
        ["class+media", ".lang-fr", "(min-width: 768px) and (-webkit-min-device-pixel-ratio: 2), (min-width: 768px) and (min-resolution: 192dpi)", "/foo.medium.2x.fr.jpg"]
      ]
    end

    it "sorts breakpoint rules" do
      stub_files("/foo.large.jpg", "/foo.medium.jpg")
      rules.should == [
        ["media", "(min-width: 768px)", "/foo.medium.jpg"],
        ["media", "(min-width: 1024px)", "/foo.large.jpg"]
      ]
    end

    it "sorts retina rules after non-retina rules" do
      stub_files("/foo.2x.large.jpg", "/foo.large.jpg")
      rules.should == [
        ["media", "(min-width: 1024px)", "/foo.large.jpg"],
        ["media", "(-webkit-min-device-pixel-ratio: 2) and (min-width: 1024px), (min-resolution: 192dpi) and (min-width: 1024px)", "/foo.2x.large.jpg"]
      ]
    end

    it "sorts breakpoints within retina rules" do
      stub_files("/foo.2x.large.jpg", "/foo.2x.medium.jpg", "/foo.2x.jpg")
      rules.should == [
        ["media", "(-webkit-min-device-pixel-ratio: 2), (min-resolution: 192dpi)", "/foo.2x.jpg"],
        ["media", "(-webkit-min-device-pixel-ratio: 2) and (min-width: 768px), (min-resolution: 192dpi) and (min-width: 768px)", "/foo.2x.medium.jpg"],
        ["media", "(-webkit-min-device-pixel-ratio: 2) and (min-width: 1024px), (min-resolution: 192dpi) and (min-width: 1024px)", "/foo.2x.large.jpg"]
      ]
    end

    it "sorts locale rules: country < lang < locale" do
      stub_files("/foo.fr.jpg", "/foo.fr-ca.jpg", "/foo.ca.jpg")
      rules.should == [
        ["class", ".country-CA", "/foo.ca.jpg"],
        ["class", ".lang-fr", "/foo.fr.jpg"],
        ["class", ".locale-fr-CA", "/foo.fr-ca.jpg"]
      ]
    end
  end

  describe ".convert_to_sass_value" do
    it "converts strings to sass strings" do
      val = Apropos.convert_to_sass_value("foo")
      val.value.should == "foo"
      val.class.should == Sass::Script::String
    end

    it "converts arrays to sass lists" do
      original_value = ["foo", "bar"]
      val = Apropos.convert_to_sass_value(original_value)
      val.class.should == Sass::Script::List
      val.value.map(&:value).should == original_value
      val.separator.should == :space
    end

    it "raises an exception on other input types" do
      expect {
        Apropos.convert_to_sass_value(3)
      }.to raise_exception
    end
  end

  describe ".images_dir" do
    context "with images_path defined" do
      let(:images_dir) { '/path/to/images' }
      it { Apropos.images_dir.to_s.should == images_dir }
    end

    context "with images_path undefined" do
      let(:images_dir) { nil }
      let(:project_dir) { '/path/to/project' }
      it { Apropos.images_dir.to_s.should == project_dir }
    end
  end
end
