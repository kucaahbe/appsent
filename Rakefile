require 'bundler/setup'
require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'
Bundler::GemHelper.install_tasks

task :default => [:spec, :features]

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts='--tag ~wip'
end

namespace :spec do

  RSpec::Core::RakeTask.new(:wip) do |t|
    t.rspec_opts='--tag wip'
  end

end

Cucumber::Rake::Task.new(:features) do |t|
  t.profile = 'default'
  t.fork = true
end
task :cucumber => :features
