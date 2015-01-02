require 'arr/connection/interpreter'

require 'timeout'

module Arr
  class Connection
    class Server
      
      def initialize(options = {})
        @options = options

        initialize_server
        initialize_interpreter
      end

      def close
        @socket.close
        @interpreter.close
      end

      def port
        @socket.addr[1]
      end

      # always has to answer something
      def send_message(message)
        @interpreter.send(message)
        # puts ">> SENT: #{text}"
        received_message = @interpreter.receive
        # puts ">> RECEIVED: #{received_message}"
      end

      def connect_interpreter
        Timeout.timeout(Arr.server_accept_timeout) do
          @socket.accept
        end
      rescue Timeout::Error
        raise Arr::Error, "Timeout connecting interpreter with server"
      end

      private

      def initialize_server
        @socket = TCPServer.new("", 0)
      end

      def initialize_interpreter
        @interpreter = Interpreter.new(self)
      end
    end
  end
end
