# encoding: utf-8
module VetCI
  class Build
   attr_accessor :id,
                 :status,
                 :date,
                 :commit,
                 :committer,
                 :payload,
                 :project
                 
                 
    def initialize(attributes = {})
      attributes.each do |key, value|
        self.send("#{key}=", value)
      end
    end
    
    def commit_info
      commit = self.project.repo.commit(self.commit)
      commit.nil? ? nil : commit.to_hash
    end
    
    def status_class
      if self.status == 0
        'passed'
      else
        'failed'
      end
    end
    
    def output
      @output
    end
    
    def output=(value)
      @output = ansi_color_codes(value)
    end
    
    # Thanks CI-Joe, and Integrity by association.
    def ansi_color_codes(string)
      string.gsub("\e[0m", '</span>').
        gsub(/\e\[(\d+)m/, "<span class=\"color\\1\">")
    end
    
    def friendly_time
      self.date.strftime('%A, %B %e, %Y at %I:%M %p')
    end
    
    def dashboard_time
      self.date.strftime('%D @ %r')
    end
  end
end