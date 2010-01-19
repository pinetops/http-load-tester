class CompletedException < Exception; end

module HttpLoadTester
  class Client
    attr_reader :client
    
    def initialize(tester)
      @client = HTTPClient.new
      @tester = tester
    end
    
    def get uri, query
      wait

      client.get uri, query

      @tester.feedback
      @tester.increment
    end
    
    def post uri, body
      wait

      client.post uri, body

      @tester.feedback
      @tester.increment
    end
    
    def wait
      rand(5).times do
        raise CompletedException.new if @tester.instance_eval { @count } >= @tester.request_limit
        sleep 1
      end
    end
  end
end
