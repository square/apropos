module Apropos
  # MediaQuery wraps a media query string with several features:
  # - Parenthesizes queries when necessary
  # - Can be combined with other MediaQuery objects
  # - Can be compared to ClassList or MediaQuery objects via #type, #sort_value
  # - Can be converted to CSS output
  class MediaQuery
    attr_reader :query_list, :sort_value

    def initialize(query_string, sort_value=0)
      @query_list = query_string.split(',').map { |q| parenthesize(q.strip) }
      @sort_value = sort_value
    end

    def parenthesize(query)
      unless query =~ /^\(.+\)$/
        "(#{query})"
      else
        query
      end
    end

    def combine(other)
      other_ql = other.query_list
      combo = query_list.map do |q|
        other_ql.map do |q2|
          "#{q} and #{q2}"
        end
      end.flatten
      self.class.new(combo.join(', '))
    end

    def to_css
      query_list.join(", ")
    end

    def type
      "media"
    end
  end
end
