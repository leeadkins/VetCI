module VetCI
  class Util
    class << self
      def open_pipe(command)
        read, write = IO.pipe
        process_id = fork do
          $stdout.reopen write
          #pth = '/Users/lee/work/lifekraze/lks-actions'
          #cmd = 'vows test/vows_test.js --spec'
          exec "cd /Users/lee/work/lifekraze/lks-actions && vows test/vows_test.js"
        end
        write.close
        yield read, process_id
      end
    end
  end
end