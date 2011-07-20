module VetCI
  class Build
    include DataMapper::Resource
    
    property :id,       Serial
    property :output,   Text
    property :status,   Integer
    property :date,     DateTime
    
    belongs_to :project
    
    
    def status_class
      if self.status == 0
        'passed'
      else
        'failed'
      end
    end
    
    def friendly_time
      self.date.strftime('%A, %B %e, %Y at %I:%M %p')
    end
  end
end