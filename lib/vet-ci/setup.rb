# Our setup script.
# encoding: utf-8
module VetCI
  class Setup
    class << self
      def go
        unless Dir.exists? '.vetci'
          Dir.mkdir '.vetci'
        end
        
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
        
        Project.datastore = PStore.new(File.join('.vetci', 'projects.pstore'))
        
        Project.parse_vetfile_contents(parameters["projects"])
        
        return parameters
      end
    end
  end
end