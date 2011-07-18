require 'vet-ci/util'

module VetCI
  class Project
  
    attr_accessor :name
    attr_accessor :project_path
    attr_accessor :build_command
    attr_reader   :last_build_date
    attr_reader   :last_build_status
    attr_reader   :last_build_result
  
    def is_building?
      @building == true
    end
  
    def initialize(n, pp, bc)
      @name = n
      @project_path = pp
      @build_command = bc
    end
  
    def status_class
      if is_building?
        return 'running'
      elsif @last_build_status == 0
        return 'passed'
      else
        return 'failed'
      end
    end
  
    def build
      if is_building?
        return
      end
    
      puts 'starting build'
      build!
    end
  
    def build!
      @building = true
      @last_build_result = ''
      Util.open_pipe("cd #{@project_path} && #{@build_command}") do |pipe, process_id|
        puts "#{Time.now.to_i}: Building..."
        @current_pid = process_id
        @last_build_result = pipe.read
      end
      Process.waitpid(@current_pid)
      @last_build_date = Time.now
      @last_build_status = $?.exitstatus
      @building = false
    end
  end
end