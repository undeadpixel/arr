require 'arr/connection/server'

module Arr
  class Connection

    def initialize(options = {})
      @options = options

      initialize_server
    end

    def close
      @server.close
    end

    def query(query)
      result = send_message({:type => 'query', :query => query})
      process_query_result(result)
    end

    private

    def send_message(message)
      result = @server.send_message(message.to_json)
      parsed_result = JSON.parse(result)
    end

    def process_query_result(result)
      case result['type']
      when 'results' then Arr::RObject.factory(result['results'])
      when 'error' then raise Arr::Error, "Query has a parse error"
      end
    end

    def initialize_server
      @server = Server.new
    end
  end
end
