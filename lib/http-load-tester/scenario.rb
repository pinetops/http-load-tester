class CompletedException < Exception; end

module HttpLoadTester
  module Scenario
    def initialize(tester)
      @client = HTTPClient.new
    end

    def get uri, query
      on_start

      response = @client.get uri, query
      
      on_completion uri, response
    end
    
    def post uri, body
      on_start

      response = @client.post uri, body

      on_completion uri, response
    end
    
    def wait
      rand(5).times do
        raise CompletedException.new if @tester.instance_eval { @count } >= @tester.request_limit
        sleep 1
      end
    end
  end
end
