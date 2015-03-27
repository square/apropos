module Apropos
  # ExtensionParser manages registered variant parsers and provides a base
  # class which new parsers subclass. Parsers are initialized with a pattern
  # (String or Regexp) and a block that is called to generate ClassList or
  # MediaQuery objects from the provided match data.
  class ExtensionParser
    @parsers = {}

    def self.parsers
      @parsers
    end

    def self.add_parser(extension, &block)
      @parsers[extension] = new(extension, &block)
    end

    def self.each_parser(&block)
      parsers.values.each(&block)
    end

    attr_reader :pattern

    def initialize(pattern, &block)
      @pattern = generate_pattern(pattern)
      @match_block = block
    end

    def match(extension)
      matchdata = pattern.match(extension)
      if matchdata
        @match_block.call(matchdata)
      end
    end

    private

    def generate_pattern(pattern)
      case pattern
      when String
        %r(^#{Regexp.escape(pattern)}$)
      else
        pattern
      end
    end
  end
end
