require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/lib/apropos/sass_functions.rb'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'apropos'
