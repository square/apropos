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
      ::Sass::Script::Functions.declare :add_dpi_image_variant, []
      ::Sass::Script::Functions.declare :add_breakpoint_image_variant, []
      ::Sass::Script::Functions.declare :nth_polyfill, [:list, :index]
      unless sass_function_exist? :str_index
        ::Sass::Script::Functions.declare :str_index, [:string, :substring]
      end
    end

    def image_variants(path)
      assert_type path, :String
      out = ::Apropos.image_variant_rules(path.value)
      ::Apropos.convert_to_sass_value(out)
    end

    def add_dpi_image_variant(id, query)
      ::Apropos.add_dpi_image_variant(id.value, query.value)
      ::Sass::Script::Bool.new(false)
    end

    def add_breakpoint_image_variant(id, query)
      ::Apropos.add_breakpoint_image_variant(id.value, query.value)
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

    # Polyfill for `str-index` function from master branch of Sass.
    # Implementation taken from:
    # https://github.com/nex3/sass/blob/master/lib/sass/script/functions.rb
    # Using Sass::Script::Number rather than Sass::Script::Value::Number for
    # backwards compatibility, however.
    unless sass_function_exist? :str_index
      def str_index(string, substring)
        assert_type string, :String, :string
        assert_type substring, :String, :substring
        index = string.value.index(substring.value) || -1
        ::Sass::Script::Number.new(index + 1)
      end
    end
  end
end
