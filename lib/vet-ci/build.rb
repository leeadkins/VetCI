module VetCI
  class Build
    attr_accessor :output
    attr_accessor :status
    attr_accessor :time
    
    def initialize(status, output, time)
      @status = status
      @time = time
      @output = output
    end
    
    def status_class
      if @status == 0
        'passed'
      else
        'failed'
      end
    end
  end
end