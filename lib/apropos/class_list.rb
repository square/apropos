module Apropos
  # ClassList wraps a list of CSS class selectors with several abilities:
  # - Can be combined with other ClassLists
  # - Can be compared to MediaQuery or ClassList objects via #sort_value, #type
  # - Can be converted to CSS output
  class ClassList
    attr_reader :list, :sort_value

    def initialize(list, sort_value=0)
      @list = list
      @sort_value = sort_value
    end

    def combine(other)
      self.class.new(list + other.list)
    end

    def to_css
      list.join(', ')
    end

    def type
      "class"
    end
  end
end
