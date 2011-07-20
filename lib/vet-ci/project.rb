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
    
    def last_build_status
      if is_building?
        return 'running'
      elsif self.builds.count > 0
        return self.builds.last.status_class
      else
        return ''
      end
    end
    
    def latest_status_class
      if is_building?
        return 'running'
      else
        return 'failed'
      end
    end
  
    def build(faye=nil)
      if is_building?
        return
      end
      Thread.new {build!(faye)}
    end
  
    def build!(faye=nil)
      unless faye.nil?
        faye.publish '/all', :project => self.name, :status => 'running'
      end
      @building = true
      @result = ''
      Util.open_pipe("cd #{@project_path} && #{@build_command}") do |pipe, process_id|
        puts "#{Time.now.to_i}: Building with command '#{@build_command}'..."
        @current_pid = process_id
        @result = pipe.read
      end
      Process.waitpid(@current_pid)
      current_build = self.builds.create(:status => $?.exitstatus.to_i, :output => @result, :date => Time.now)
      puts "Saving build..."
      unless faye.nil?
        faye.publish '/all', :project => self.name, :status => current_build.status_class
      end
      @building = false
    end
  end
end