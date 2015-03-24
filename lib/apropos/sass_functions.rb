module Apropos
  # A collection of methods mixed into Sass::Script::Functions to allow
  # Apropos to be used from Sass files. The primary method is
  # `image-variants`, which generates the actual CSS rules.  Configuration
  # directly from the Sass file is possible with the `add-dpi-image-variant`
  # and `add-breakpoint-image-variant` methods, although the limitations of
  # Sass syntax require that the output of these functions be assigned to a
  # dummy variable.
  module SassFunctions
    def self.sass_function_exist?(meth)
      Sass::Script::Functions.instance_methods.include? meth
    end

    def self.included(mod)
      ::Sass::Script::Functions.declare :image_variants, []
      ::Sass::Script::Functions.declare :apropos_image_height, [:string]
      ::Sass::Script::Functions.declare :add_dpi_image_variant, []
      ::Sass::Script::Functions.declare :add_breakpoint_image_variant, []
      ::Sass::Script::Functions.declare :nth_polyfill, [:list, :index]
      ::Sass::Script::Functions.declare :str_contains, [:string, :substring]
    end

    def self.value(val)
      val.respond_to?(:value) ? val.value : val
    end

    def image_variants(path)
      assert_type path, :String
      set = ::Apropos.image_set(path.value)
      set.invalid_variants.each do |variant|
        message = "Ignoring unknown extensions " +
          "'#{variant.invalid_codes.join("', '")}' (#{variant.path})"
        ::Sass.logger.info message
        $stderr.puts message
      end
      ::Apropos.convert_to_sass_value(set.valid_variant_rules)
    end

    def apropos_image_height(path)
      assert_type path, :String
      height = image_height(path)
      if ::Apropos.hidpi_only
        ::Sass::Script::Number.new(
          (height.value / 2).floor,
          height.numerator_units,
          height.denominator_units
        )
      else
        height
      end
    end

    def add_dpi_image_variant(id, query, sort=0)
      sort = ::Apropos::SassFunctions.value(sort)
      ::Apropos.add_dpi_image_variant(id.value, query.value, sort)
      ::Sass::Script::Bool.new(false)
    end

    def add_breakpoint_image_variant(id, query, sort=0)
      sort = ::Apropos::SassFunctions.value(sort)
      ::Apropos.add_breakpoint_image_variant(id.value, query.value, sort)
      ::Sass::Script::Bool.new(false)
    end

    # Can be replaced with stock `nth` once dca1498 makes it into a Sass release
    # http://git.io/eGNOKA
    def nth_polyfill(list, index)
      index = index.value
      list = list.value
      index = list.length + index + 1 if index < 0
      list[index - 1]
    end

    def str_contains(string, substring)
      assert_type string, :String, :string
      assert_type substring, :String, :substring
      ::Sass::Script::Bool.new(string.value.include?(substring.value))
    end
  end
end
