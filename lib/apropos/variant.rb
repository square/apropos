module Apropos
  # A Variant represents a single image file that should be displayed instead
  # of the base image in one or more conditions. These conditions are parsed
  # from the codes in the provided code fragment. If none of the available
  # parsers can understand the Variant's codes, then the Variant is not
  # considered valid.
  #
  # A valid Variant can generate a CSS rule from its matching conditions, and
  # can be compared to other Variants based on the aggregate sort values of its
  # matching conditions.
  class Variant
    attr_reader :path

    def initialize(code_fragment, path)
      @code_fragment = code_fragment
      @path = path
      @_invalid_codes = []
    end

    def codes
      @_codes ||= @code_fragment.split(SEPARATOR)
    end

    def conditions
      parse_codes && @_conditions
    end

    def invalid_codes
      parse_codes && @_invalid_codes
    end

    def conditions_by_type
      @_conditions_by_type ||= {}.tap do |combination|
        conditions.each do |condition|
          combination[condition.type] = if combination[condition.type]
            combination[condition.type].combine(condition)
          else
            condition
          end
        end
      end
    end

    def valid?
      !conditions.empty? && @_invalid_codes.empty?
    end

    def rule
      sorted_selector_types = conditions_by_type.keys.sort
      condition_css = sorted_selector_types.map do |rule_type|
        conditions_by_type[rule_type].to_css
      end
      key = sorted_selector_types.join('+')
      [key] + condition_css + [path]
    end

    def aggregate_sort_value
      conditions.inject(0) do |total, query_or_selector|
        total + query_or_selector.sort_value
      end
    end

    def <=>(other)
      aggregate_sort_value <=> other.aggregate_sort_value
    end

    private
    def parse_codes
      @_conditions ||= codes.map do |code|
        ExtensionParser.each_parser.inject(nil) do |_, parser|
          query_or_selector = parser.match(code)
          break query_or_selector if query_or_selector
        end.tap do |match|
          # Track codes not recognized by any parser
          @_invalid_codes << code unless match
        end
      end.compact
    end
  end
end
