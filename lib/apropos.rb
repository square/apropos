require 'compass'

module Apropos
  SEPARATOR = '.'
  STYLESHEETS_DIR = File.expand_path('../../stylesheets', __FILE__)
end

Dir.glob(File.expand_path('../apropos/*.rb', __FILE__), &method(:require))

module Sass::Script::Functions
  include Apropos::SassFunctions
end

Compass::Frameworks.register('apropos', {
  :stylesheets_directory => Apropos::STYLESHEETS_DIR
})
