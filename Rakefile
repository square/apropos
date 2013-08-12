require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

begin
  require 'cane/rake_task'

  desc "Run cane to check quality metrics"
  Cane::RakeTask.new(:quality) do |cane|
    cane.abc_max = 10
    cane.style_glob = 'lib/**/*.rb'
  end

  task :default => :quality
rescue LoadError
  warn "cane not available, quality task not provided."
end
