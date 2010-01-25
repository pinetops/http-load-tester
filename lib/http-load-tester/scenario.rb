class CompletedException < Exception; end

module HttpLoadTester
  module Scenario
    def initialize(tester)
      @client = HTTPClient.new
      if ENV["DEBUG"]
        @client.debug_dev = STDOUT
      end
    end

    def add_cookie cookie
      @client.cookie_manager.add cookie
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
  end
end
