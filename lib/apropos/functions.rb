# The Apropos module provides several functions for configuration and for
# supplying rules to the Sass functions. See the README for configuration
# examples.
#
# It also provides convenience functions used by the Sass functions.
module Apropos
  HIDPI_VARIANT_WARNING = 'DPI variant images detected in hidpi-only mode!'.freeze

  class << self
    attr_accessor :hidpi_only
  end

  module_function

  def image_set(path)
    Set.new(path, images_dir)
  end

  def image_variant_rules(path)
    image_set(path).valid_variants.map(&:rule)
  end

  def add_dpi_image_variant(id, query, order=0)
    ExtensionParser.add_parser(id) do |match|
      Sass.logger.warn(HIDPI_VARIANT_WARNING) if hidpi_only
      MediaQuery.new(query, order)
    end
  end

  def add_breakpoint_image_variant(id, query, order=0)
    ExtensionParser.add_parser(id) do |match|
      MediaQuery.new(query, order)
    end
  end

  def add_class_image_variant(id, class_list=[], order=0, &block)
    parser = if block_given?
      lambda do |match|
        result = block.call(match)
        create_class_rule(result) if result
      end
    else
      lambda do |match|
        create_class_rule(class_list, order)
      end
    end

    ExtensionParser.add_parser(id, &parser)
  end

  def create_class_rule(class_list, order=0)
    list = Array(class_list).map {|name| name[0] == '.' ? name : ".#{name}"}
    ClassList.new(list, order)
  end

  def clear_image_variants
    ExtensionParser.parsers.clear
  end

  def images_dir
    config = Compass.configuration
    Pathname.new(config.images_path || config.project_path)
  end

  def convert_to_sass_value(val)
    case val
    when String
      Sass::Script::String.new(val)
    when Array
      converted = val.map {|element| convert_to_sass_value(element) }
      Sass::Script::List.new(converted, :space)
    else
      raise "convert_to_sass_value doesn't understand type #{val.class.inspect}"
    end
  end
end
