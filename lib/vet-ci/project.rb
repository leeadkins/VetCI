require 'vet-ci/util'
require 'vet-ci/build'

module VetCI
  class Project
    include DataMapper::Resource
    
    property :id,             Serial
    property :name,           String
    property :project_path,   String
    property :build_command,  String
    has n,   :builds
    
    validates_uniqueness_of :name
    
    def is_building?
      @building == true
    end
    
    def latest_build
    
    end
  
    def latest_status_class
      if is_building?
        return 'running'
      else
        return 'failed'
      end
    end
  
    def build
      if is_building?
        return
      end
      Thread.new {build!}
    end
  
    def build!
      @building = true
      @result = ''
      Util.open_pipe("cd #{@project_path} && #{@build_command}") do |pipe, process_id|
        puts "#{Time.now.to_i}: Building with command '#{@build_command}'..."
        @current_pid = process_id
        @result = pipe.read
      end
      Process.waitpid(@current_pid)
      latest_build = Build.create(
        :status => $?exitstatus.to_i,
        :output => @result,
        :date => Time.now,
        :project => @name
      )
      @building = false
    end
  end
end