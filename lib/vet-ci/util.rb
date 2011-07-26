# encoding: utf-8
module VetCI
  class Util
    class << self
      def open_pipe(command)
        read, write = IO.pipe
        process_id = fork do
          $stdout.reopen write
          exec command
        end
        write.close
        yield read, process_id
      end
    end
  end
end