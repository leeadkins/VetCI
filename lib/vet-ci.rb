require 'vet-ci/setup'
require 'vet-ci/version'
require 'vet-ci/server'
require 'yaml'

module VetCI
  class Core
    def initialize
      VetCI::Setup.go
    end
    
    def start
      VetCI::Server.start(self)
    end
  end
end
