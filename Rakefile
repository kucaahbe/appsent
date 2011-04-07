require 'bundler'
require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'
Bundler::GemHelper.install_tasks

task :default => :spec

RSpec::Core::RakeTask.new(:spec)

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "--format pretty"
end
