class CompletedException < Exception; end

module HttpLoadTester
  module Scenario
    def initialize(tester)
      @client = HTTPClient.new
    end

    def get uri, query
      on_start

      @client.get uri, query

      on_completion
    end
    
    def post uri, body
      on_start

      @client.post uri, body

      on_completion
    end
    
    def wait
      rand(5).times do
        raise CompletedException.new if @tester.instance_eval { @count } >= @tester.request_limit
        sleep 1
      end
    end
  end
end
