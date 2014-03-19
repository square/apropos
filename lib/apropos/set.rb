module Apropos
  # A Set generates a list of Variants from a base image path. Any file in the
  # same directory as the base image with the pattern "basename.*.extension" is
  # considered to be a potential Variant, though not all generated Variants are
  # guaranteed to be valid.
  class Set
    attr_reader :path

    def initialize(path, basedir)
      @path = path
      @basedir = Pathname.new(basedir)
    end

    def variants
      variant_paths.map do |code_fragment, path|
        Variant.new(code_fragment, path)
      end.sort
    end

    def valid_variants
      variants.select(&:valid?)
    end

    def invalid_variants
      variants.reject(&:valid?)
    end

    def valid_variant_rules
      valid_variants.map(&:rule)
    end

    def variant_paths
      paths = {}
      self.class.glob(@basedir.join(variant_path_glob)).each do |path|
        key = code_fragment(path)
        paths[key] = remove_basedir(path)
      end
      paths
    end

    def remove_basedir(path)
      path.sub(basedir_re, '')
    end

    def basedir_re
      @basedir_re ||= Regexp.new("^.*#{Regexp.escape(@basedir.to_s)}/")
    end

    def code_fragment(path)
      start = File.join(File.dirname(path), basename)
      path[(start.length + 1)...(path.length - extname.length)]
    end

    def variant_path_glob
      Pathname.new(dirname).join("#{basename}#{SEPARATOR}*#{extname}")
    end

    def dirname
      @dirname ||= File.dirname(@path)
    end

    def basename
      @basename ||= File.basename(@path, extname)
    end

    def extname
      @extname ||= File.extname(@path)
    end

    # Wrapper for Dir.glob to make test stubbing cleaner
    def self.glob(path)
      Dir.glob(path)
    end
  end
end
