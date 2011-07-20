require 'vet-ci/util'
require 'vet-ci/build'

module VetCI
  class Project
  
    attr_accessor :name
    attr_accessor :project_path
    attr_accessor :build_command
    attr_reader   :builds
    
    def is_building?
      @building == true
    end
    
    def latest_build
      @build[0]
    end
  
    def initialize(n, pp, bc)
      @builds = []
      @name = n
      @project_path = pp
      @build_command = bc
    end
  
    def latest_status_class
      if is_building?
        return 'running'
      elsif !@builds[0].nil?
        return @builds[0].status_class
      else
        return 'failed'
      end
    end
  
    def build
      if is_building?
        return
      end
    
      puts 'starting build'
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
      puts $?
      @builds.unshift(Build.new($?.exitstatus.to_i, @result, Time.now))
      @building = false
    end
  end
end