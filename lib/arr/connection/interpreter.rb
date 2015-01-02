module Arr
  class Connection
    class Interpreter

      def initialize(server, options = {})
        @server = server
        @options = options

        initialize_interpreter
        initialize_destructor
        initialize_connection
      end

      def close
        self.class.finalize(pid)
        @io.close
        @socket.close
      end

      def self.finalize(pid)
        Process.kill("KILL", pid)
      end

      def self.finalize_proc(pid)
        proc { self.finalize(pid) }
      end

      def pid
        @io.pid
      end

      def send(text)
        @socket.puts(text)
        @socket.flush
      end

      def receive
        Timeout.timeout(Arr.interpreter_query_timeout) do
          @socket.readline
        end
      rescue Timeout::Error
        raise Arr::Error, "Timeout executing query"
      end

      private

      def initialize_interpreter
        @io = IO.popen(r_command, 'w+', :err => '/dev/null')

        load_functions
      end

      def initialize_connection
        run_code <<-R
          SOCKET = connectToServer(#{@server.port})
          listenToMessages()
        R

        @socket = @server.connect_interpreter
      end

      def initialize_destructor
        ObjectSpace.define_finalizer(self, self.class.finalize_proc(pid))
      end

      def run_code(code)
        @io.puts(code)
        @io.flush
      end

      def r_command
        "R --slave --vanilla"
      end

      def load_functions
        run_code <<-R
          source("#{Arr.r_sources_dir_path}/client.r")
        R
      end
    end
  end
end
