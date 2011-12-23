require 'bundler/setup'
require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'
begin
require 'relish/rake/tasks'
rescue LoadError
end
Bundler::GemHelper.install_tasks

task :default => [:spec, :features]

namespace :spec do

  desc "" # to hide task
  RSpec::Core::RakeTask.new(:default) do |t|
    t.rspec_opts='--tag ~wip'
  end

  desc "run work in progress specs"
  RSpec::Core::RakeTask.new(:wip) do |t|
    t.rspec_opts='--tag wip'
  end

end
desc "run specs"
task :spec => 'spec:default'

Cucumber::Rake::Task.new(:features) do |t|
  t.profile = 'default'
  t.fork = true
end
desc "alias for 'features'"
task :cucumber => :features

if defined?(Relish)
namespace :relish do
  Relish::Rake::PushTask.new(:push) do |t|
    t.project_name = 'appsent'
    t.version      = AppSent::VERSION
  end
end
end
