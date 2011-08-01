require 'bundler/setup'
require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'
Bundler::GemHelper.install_tasks

task :default => [:spec, :features]

RSpec::Core::RakeTask.new(:spec)

Cucumber::Rake::Task.new(:features) do |t|
  t.profile = 'default'
  t.fork = true
end
task :cucumber => :features
