# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "appsent/version"

Gem::Specification.new do |s|
  s.name        = "appsent"
  s.version     = AppSent::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["kucaahbe"]
  s.email       = ["kucaahbe@ukr.net"]
  s.homepage    = "http://github.com/kucaahbe/appsent"
  s.summary     = %q{config management solution}
  s.description = s.summary

  s.rubyforge_project = "appsent"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'yard'
  s.add_development_dependency 'BlueCloth'
  s.add_development_dependency 'RedCloth'
  s.add_development_dependency 'rspec', '>= 2.0.0'
  s.add_development_dependency 'aruba'
  s.add_development_dependency 'rake'
end
