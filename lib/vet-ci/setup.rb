# Our setup script.
require 'data_mapper'
require 'vet-ci/project'
require 'vet-ci/build'

module VetCI
  class Setup
    class << self
      def go
        unless Dir.exists? '.vetci'
          Dir.mkdir '.vetci'
        end

        path = File.join Dir.pwd, '.vetci', 'data.db'

        DataMapper.setup(:default, "sqlite://#{path}")

        DataMapper.auto_upgrade!
        
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

        # Once we have a Vetfile, we want to make sure each project has
        # an entry in our SQLite database
        
        # Kill all the ones that aren't in the Vetfile
        parameters.each do |project|
          name = project['name']
          path = project['path']
          command = project['command']
          branch = project['branch']
          if path.nil?
            path = Dir.pwd
          else
            path = File.expand_path path
          end
          
          Project.create(:name => name, :project_path => path, :build_command => command)
          
        end        
      end
    end
  end
end