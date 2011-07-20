require 'vet-ci/version'
require 'vet-ci/server'
require 'vet-ci/project'
require 'yaml'

module VetCI
  class Core
    attr_accessor :projects
  
    def initialize
      @projects = {}
      load_projects_from_vetfiles
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
        if path.nil?
          path = Dir.pwd
        else
          path = File.expand_path path
        end
        if command.nil?
          
        else
          project = Project.new(name, path, command)
          @projects[name] = project
        end        
      end
    end
  end
end
