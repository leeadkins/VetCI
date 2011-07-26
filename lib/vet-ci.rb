require 'vet-ci/version'
require 'vet-ci/project'
require 'vet-ci/build'
require 'vet-ci/setup'
require 'vet-ci/server'
require 'yaml'
require 'grit'

module VetCI
  class Core
    attr_accessor :vetfile
    def initialize
      self.vetfile = VetCI::Setup.go
    end
    
    def start
      VetCI::Server.start
    end
  end
end
