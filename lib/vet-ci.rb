require 'vet-ci/setup'
require 'vet-ci/version'
require 'vet-ci/server'
require 'yaml'

module VetCI
  class Core
    def start
      VetCI::Server.start
    end
  end
end
