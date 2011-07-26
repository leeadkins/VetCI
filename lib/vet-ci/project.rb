require 'pstore'
require 'vet-ci/util'
require 'vet-ci/build'
require 'grit'
require 'json'

module VetCI
  class Project
    
    class << self
      # This shouldn't be here,
      # but it was easy. We'll refactor it 
      # when that time comes...
      
      def projects
        @projects ||= {}
      end
      
      def projects=(value)
        @projects = value
      end
      
      def datastore
        @datastore
      end
      
      def datastore=(value)
        @datastore = value
      end
      
      #Returns a project in the list that is named .. 
      def named(value)
        self.projects[value]
      end
      
      def parse_vetfile_contents(parameters)
        parameters.each do |project|
          name = project['name']
          path = project['path']
          command = project['command']
          default_branch = project['default_branch']
          autoupdate = (project['autoupdate'].nil? ? false : project['autoupdate'])
          
          if path.nil?
            path = Dir.pwd
          else
            path = File.expand_path path
          end
          
          project = Project.new(:name => name, :project_path => path, :build_command => command, :default_branch => default_branch, :autoupdate => autoupdate)
          
          self.projects[project.name] = project
        end
      end
    end
    
    attr_accessor :name
    attr_accessor :project_path
    attr_accessor :build_command
    attr_accessor :default_branch
    attr_accessor :autoupdate
    attr_accessor :building
    

    def builds
      @builds ||= []
    end
    
    def pagedBuilds(page=1, limit=10)
      # We need to calculate the slice
      page = page.nil? ? 1 : page.to_i
      limit = limit.nil? ? 10 : limit.to_i
      page = 1 if page < 0
      start = (page-1) * limit
      # limit is the length
      result = self.builds[start,limit]
      result.nil? ? [] : result
    end
    
    def builds=(value)
      @builds = value
    end
    
    def insertBuild(build)
      self.builds << build
      @builds.sort! do |a, b|
        if a.date == b.date
          0
        elsif a.date < b.date
          1
        else
          -1
        end
      end
    end
    
    def initialize(attributes = {})
      attributes.each do |key, value|
        self.send("#{key}=", value)
      end
      
      # Now, let's load any existing builds in the list from the datastore
      unless Project.datastore.nil?
        Project.datastore.transaction(true) do
          builds = Project.datastore[self.name]
          self.builds.concat(builds) unless builds.nil?
        end
      end
    end
    
    def save!
      unless Project.datastore.nil?
        Project.datastore.transaction do
          Project.datastore[self.name] = @builds
        end
      end
    end
    
    def git_update
      reset_branch = self.default_branch.nil? ? "" : " origin/#{self.default_branch}"
      `cd #{self.project_path} && git fetch origin && git reset --hard#{reset_branch}`
    end
    
    def repo
      Grit::Repo.new(self.project_path)
    end
    
    def is_building?
      self.building == true
    end
    
    def last_build_status
      if is_building?
        return 'running'
      elsif self.builds.count > 0
        return self.builds.first.status_class
      else
        return ''
      end
    end
  
    def build(faye=nil, payload=nil)
      if is_building?
        return
      end
      
      if payload
        begin
          payload = JSON.parse payload
        rescue
          payload = nil
        end
      end
      
      Thread.new {build!(faye, payload)}
    end
  
    def build!(faye=nil, payload=nil)
      self.building = true
    
      unless faye.nil?
        faye.publish '/all', :project => self.name, :status => 'running'
      end
      
      # First, let's reset the repo if we said we should in the Vetfile
      if self.autoupdate == true
        puts "Updating the repo"
        self.git_update
      end
    
      @result = ''
      repo = Grit::Repo.new @project_path
      commit = repo.commits.first
      Util.open_pipe("cd #{@project_path} && #{@build_command} 2>&1") do |pipe, process_id|
        puts "#{Time.now.to_i}: Building with command '#{@build_command}'..."
        @current_pid = process_id
        @result = pipe.read
      end
      Process.waitpid(@current_pid)
      puts $?.exitstatus.to_i
      if commit.nil?
        current_build = Build.new(:project => self, :status => $?.exitstatus.to_i, :output => @result, :date => Time.now, :payload => payload)
      else
        current_build = Build.new(:project => self, :status => $?.exitstatus.to_i, :output => @result, :date => Time.now, :commit => commit.id, :committer => commit.committer.name, :payload => payload)
      end

      puts "Saving build..."
      unless faye.nil?
        faye.publish '/all', :project => self.name, :status => current_build.status_class, :last_build => current_build.dashboard_time
      end
      
      self.insertBuild current_build
      self.building = false
      self.save!
    end
  end
end