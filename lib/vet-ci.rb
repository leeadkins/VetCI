require 'vet-ci/setup'
require 'vet-ci/version'
require 'vet-ci/server'
require 'vet-ci/project'
require 'vet-ci/build'
require 'yaml'
require 'grit'

module VetCI
  class Core
    def initialize
      VetCI::Setup.go
    end
    
    def start
      VetCI::Server.start
    end
  end
end
