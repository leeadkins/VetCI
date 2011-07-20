# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "vet-ci/version"

Gem::Specification.new do |s|
  s.name        = "vet-ci"
  s.version     = Vet::Ci::VERSION
  s.authors     = ["Lee Adkins"]
  s.email       = ["lee@ravsonic.com"]
  s.homepage    = "http://github.com/leeadkins/vet-ci"
  s.summary     = %q{Make sure your little code pets get their checkups.}
  s.description = %q{VetCI is a continuous intergration system.}

  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  #s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.executables   = %w( vet-ci )
  s.require_paths = ["lib"]
  
  
  
  s.add_runtime_dependency   'sinatra'
  s.add_runtime_dependency   'grit'
  s.add_runtime_dependency   'choice'
  s.add_runtime_dependency   'faye'
  
  s.add_development_dependency 'rake'
end
