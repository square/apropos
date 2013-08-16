require 'compass'

module Apropos
  SEPARATOR = '.'
end

here = File.dirname(__FILE__)
Dir.glob(File.join(here, 'apropos', '*.rb'), &method(:require))

module Sass::Script::Functions
  include Apropos::SassFunctions
end

stylesheets_directory = File.expand_path(File.join(here, '..', 'stylesheets'))
Compass::Frameworks.register('apropos', {
  :stylesheets_directory => stylesheets_directory
})
