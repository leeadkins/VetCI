module VetCI
  class Build
    include DataMapper::Resource
    property :id,       Serial
    property :output,   Text
    property :status,   Integer
    property :time,     DateTime
    property :project,  String
    
    belongs_to :project
    
    
    def status_class
      if self.status == 0
        'passed'
      else
        'failed'
      end
    end
  end
end