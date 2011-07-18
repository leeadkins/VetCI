require 'vet-ci/version'
require 'vet-ci/server'
require 'vet-ci/project'
require 'yaml'

module VetCI
  class Core
    attr_accessor :projects
  
    def initialize
      load_projects_from_vetfiles
      #pth = '/Users/lee/work/lifekraze/lks-actions'
      #cmd = 'vows test/vows_test.js --spec'
      #cmd = 'vows test/vows_test.js'
      #@builder = VetCI::Project.new pth, cmd

      #@builder.build
    end
    
    def start
      VetCI::Server.start(self)
    end
    
    protected
    def load_projects_from_vetfiles
      unless File.exists? 'Vetfile'
        puts "No Vetfile found. Please create one and try again."
        Process.exit
      end
      
      begin
        parameters = YAML.load(File.read('Vetfile'))
      rescue
        puts "Unable to load Vetfile. Check its syntax and try again."
        Process.exit
      end
      
      parameters.each do |project|
        name = project['name']
        path = project['path']
        command = project['command']
        if path.blank?
          path = Dir.pwd
        end
        project = Project.new(name, path, command)
        @projects << project
      end
    end
  end
end
