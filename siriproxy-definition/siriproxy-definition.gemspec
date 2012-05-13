# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-definition"
  s.version     = "0.2.2" 
  s.authors     = ["cedbv"]
  s.email       = [""]
  s.homepage    = ""
  s.summary     = %q{Définition}
  s.description = %q{Définition en français}

  s.rubyforge_project = "siriproxy-definition"

  s.files         = `git ls-files 2> /dev/null`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/* 2> /dev/null`.split("\n")
  s.executables   = `git ls-files -- bin/* 2> /dev/null`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "httparty"
  s.add_runtime_dependency "active_support"
  s.add_runtime_dependency "i18n"
end
